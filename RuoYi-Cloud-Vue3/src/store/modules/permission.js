import auth from '@/plugins/auth'
import useUserStore from '@/store/modules/user'
import router, { constantRoutes, dynamicRoutes } from '@/router'
import { getRouters } from '@/api/menu'
import Layout from '@/layout/index'
import ParentView from '@/components/ParentView'
import InnerLink from '@/layout/components/InnerLink'

// 匹配views里面所有的.vue文件
const modules = import.meta.glob('./../../views/**/*.vue')

const usePermissionStore = defineStore(
  'permission',
  {
    state: () => ({
      routes: [],
      addRoutes: [],
      defaultRoutes: [],
      topbarRouters: [],
      sidebarRouters: []
    }),
    actions: {
      setRoutes(routes) {
        this.addRoutes = routes
        this.routes = constantRoutes.concat(routes)
      },
      setDefaultRoutes(routes) {
        this.defaultRoutes = constantRoutes.concat(routes)
      },
      setTopbarRoutes(routes) {
        this.topbarRouters = routes
      },
      setSidebarRouters(routes) {
        this.sidebarRouters = routes
      },
      generateRoutes(roles) {
        return new Promise(resolve => {
          const userStore = useUserStore()
          const loginType = userStore.loginType
          
          // 如果是患者或医生，直接使用默认菜单，不请求后端（因为他们不在 sys_user 表中，后端会返回空）
          if (loginType === 'patient' || loginType === 'doctor') {
            const menuData = this.getDefaultMenuByLoginType(loginType)
            const sdata = JSON.parse(JSON.stringify(menuData))
            const rdata = JSON.parse(JSON.stringify(menuData))
            const defaultData = JSON.parse(JSON.stringify(menuData))
            const sidebarRoutes = filterAsyncRouter(sdata)
            const rewriteRoutes = filterAsyncRouter(rdata, false, true)
            const defaultRoutes = filterAsyncRouter(defaultData)
            const asyncRoutes = filterDynamicRoutes(dynamicRoutes)
            asyncRoutes.forEach(route => { router.addRoute(route) })
            
            // 对于患者和医生，sidebarRouters 只包含业务菜单，不包含 constantRoutes
            this.setRoutes(rewriteRoutes)
            this.setSidebarRouters(sidebarRoutes) 
            this.setDefaultRoutes(sidebarRoutes)
            this.setTopbarRoutes(defaultRoutes)
            resolve(rewriteRoutes)
            return
          }

          // 向后端请求路由数据
          getRouters().then(res => {
            let menuData = res.data
            
            const sdata = JSON.parse(JSON.stringify(menuData))
            const rdata = JSON.parse(JSON.stringify(menuData))
            const defaultData = JSON.parse(JSON.stringify(menuData))
            const sidebarRoutes = filterAsyncRouter(sdata)
            const rewriteRoutes = filterAsyncRouter(rdata, false, true)
            const defaultRoutes = filterAsyncRouter(defaultData)
            const asyncRoutes = filterDynamicRoutes(dynamicRoutes)
            asyncRoutes.forEach(route => { router.addRoute(route) })
            this.setRoutes(rewriteRoutes)
            this.setSidebarRouters(constantRoutes.concat(sidebarRoutes))
            this.setDefaultRoutes(sidebarRoutes)
            this.setTopbarRoutes(defaultRoutes)
            resolve(rewriteRoutes)
          })
        })
      },
      getDefaultMenuByLoginType(type) {
        if (type === 'patient') {
          return [
            {
              name: 'Hospital',
              path: '/hospital',
              hidden: false,
              redirect: 'noRedirect',
              component: 'Layout',
              alwaysShow: true,
              meta: { title: '医疗服务', icon: 'hospital', noCache: false, link: null },
              children: [
                {
                  name: 'Register',
                  path: 'register',
                  hidden: false,
                  component: 'hospital/appointment/register',
                  meta: { title: '预约挂号', icon: 'edit', noCache: false, link: null }
                },
                {
                  name: 'Appointment',
                  path: 'appointment',
                  hidden: false,
                  component: 'hospital/appointment/index',
                  meta: { title: '我的预约', icon: 'list', noCache: false, link: null }
                },
                {
                  name: 'Record',
                  path: 'record',
                  hidden: false,
                  component: 'hospital/record/index',
                  meta: { title: '我的病历', icon: 'form', noCache: false, link: null }
                }
              ]
            }
          ]
        } else if (type === 'doctor') {
          return [
            {
              name: 'Hospital',
              path: '/hospital',
              hidden: false,
              redirect: 'noRedirect',
              component: 'Layout',
              alwaysShow: true,
              meta: { title: '医疗业务', icon: 'hospital', noCache: false, link: null },
              children: [
                {
                  name: 'Schedule',
                  path: 'schedule',
                  hidden: false,
                  component: 'hospital/schedule/index',
                  meta: { title: '我的排班', icon: 'date', noCache: false, link: null }
                },
                {
                  name: 'Appointment',
                  path: 'appointment',
                  hidden: false,
                  component: 'hospital/appointment/index',
                  meta: { title: '预约列表', icon: 'list', noCache: false, link: null }
                },
                {
                  name: 'Record',
                  path: 'record',
                  hidden: false,
                  component: 'hospital/record/index',
                  meta: { title: '病历管理', icon: 'form', noCache: false, link: null }
                }
              ]
            }
          ]
        }
        return []
      }
    }
  })

// 遍历后台传来的路由字符串，转换为组件对象
function filterAsyncRouter(asyncRouterMap, lastRouter = false, type = false) {
  return asyncRouterMap.filter(route => {
    if (type && route.children) {
      route.children = filterChildren(route.children)
    }
    if (route.component) {
      // Layout ParentView 组件特殊处理
      if (route.component === 'Layout') {
        route.component = Layout
      } else if (route.component === 'ParentView') {
        route.component = ParentView
      } else if (route.component === 'InnerLink') {
        route.component = InnerLink
      } else {
        route.component = loadView(route.component)
      }
    }
    if (route.children != null && route.children && route.children.length) {
      route.children = filterAsyncRouter(route.children, route, type)
    } else {
      delete route['children']
      delete route['redirect']
    }
    return true
  })
}

function filterChildren(childrenMap, lastRouter = false) {
  var children = []
  childrenMap.forEach(el => {
    el.path = lastRouter ? lastRouter.path + '/' + el.path : el.path
    if (el.children && el.children.length && el.component === 'ParentView') {
      children = children.concat(filterChildren(el.children, el))
    } else {
      children.push(el)
    }
  })
  return children
}

// 动态路由遍历，验证是否具备权限
export function filterDynamicRoutes(routes) {
  const res = []
  routes.forEach(route => {
    if (route.permissions) {
      if (auth.hasPermiOr(route.permissions)) {
        res.push(route)
      }
    } else if (route.roles) {
      if (auth.hasRoleOr(route.roles)) {
        res.push(route)
      }
    }
  })
  return res
}

export const loadView = (view) => {
  let res
  for (const path in modules) {
    const dir = path.split('views/')[1].split('.vue')[0]
    if (dir === view) {
      res = () => modules[path]()
    }
  }
  return res
}

export default usePermissionStore
