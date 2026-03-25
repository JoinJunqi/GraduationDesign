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
          
          // 本项目的菜单生成分两条链路：
          // 1) patient/doctor/guest：前端本地菜单（固定业务入口，避免依赖后台菜单配置）
          // 2) admin：后端返回菜单（按权限动态渲染）
          // 如果是患者或医生或访客，直接使用默认菜单
          if (loginType === 'patient' || loginType === 'doctor' || loginType === 'guest') {
            const menuData = this.getDefaultMenuByLoginType(loginType)
            const sdata = JSON.parse(JSON.stringify(menuData))
            const rdata = JSON.parse(JSON.stringify(menuData))
            const defaultData = JSON.parse(JSON.stringify(menuData))
            const sidebarRoutes = filterAsyncRouter(sdata)
            const rewriteRoutes = filterAsyncRouter(rdata, false, true)
            const defaultRoutes = filterAsyncRouter(defaultData)
            const asyncRoutes = filterDynamicRoutes(dynamicRoutes)
            asyncRoutes.forEach(route => { router.addRoute(route) })
            
            // sidebar = 公共固定路由(constantRoutes) + 当前登录类型业务菜单
            // rewriteRoutes 用于权限路由树渲染，default/topbar 用于顶部与默认展示
            this.setRoutes(rewriteRoutes)
            this.setSidebarRouters(constantRoutes.concat(sidebarRoutes)) 
            this.setDefaultRoutes(sidebarRoutes)
            this.setTopbarRoutes(defaultRoutes)
            resolve(rewriteRoutes)
            return
          }

          // 向后端请求路由数据
          getRouters().then(res => {
            let menuData = res.data
            
            // 路由去重处理（防止后端返回重复的根菜单）
            const seenPaths = new Set();
            menuData = menuData.filter(route => {
              const fullPath = route.path.startsWith('/') ? route.path : '/' + route.path;
              if (seenPaths.has(fullPath)) {
                return false;
              }
              seenPaths.add(fullPath);
              
              // 移除管理员界面的“预约挂号”功能入口（预约挂号是患者端功能）
              if (fullPath === '/hospital') {
                if (route.children) {
                  route.children = route.children.filter(child => 
                    child.path !== 'register' && child.name !== 'Register' && 
                    child.meta?.title !== '预约挂号'
                  );
                }
              }
              return true;
            });
            
            const sdata = JSON.parse(JSON.stringify(menuData))
            const rdata = JSON.parse(JSON.stringify(menuData))
            const defaultData = JSON.parse(JSON.stringify(menuData))
            const sidebarRoutes = filterAsyncRouter(sdata)
            const rewriteRoutes = filterAsyncRouter(rdata, false, true)
            const defaultRoutes = filterAsyncRouter(defaultData)
            const asyncRoutes = filterDynamicRoutes(dynamicRoutes)
            asyncRoutes.forEach(route => { router.addRoute(route) })

            // 管理员菜单来源于后端，便于后续做精细化权限与菜单可配置化
            this.setRoutes(rewriteRoutes)
            this.setSidebarRouters(constantRoutes.concat(sidebarRoutes))
            this.setDefaultRoutes(sidebarRoutes)
            this.setTopbarRoutes(defaultRoutes)
            resolve(rewriteRoutes)
          })
        })
      },
      getDefaultMenuByLoginType(type) {
        if (type === 'guest') {
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
        } else if (type === 'patient') {
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
      // 递归处理子路由，把字符串组件名映射为真实组件
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
      // 懒加载视图，降低首屏包体积
      res = () => modules[path]()
    }
  }
  return res
}

export default usePermissionStore
