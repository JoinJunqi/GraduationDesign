import router from './router'
import { ElMessage, ElMessageBox } from 'element-plus'
import NProgress from 'nprogress'
import 'nprogress/nprogress.css'
import { getToken } from '@/utils/auth'
import { isHttp, isPathMatch } from '@/utils/validate'
import { isRelogin } from '@/utils/request'
import useUserStore from '@/store/modules/user'
import useSettingsStore from '@/store/modules/settings'
import usePermissionStore from '@/store/modules/permission'

NProgress.configure({ showSpinner: false })

const whiteList = ['/login', '/register']

const isWhiteList = (path) => {
  return whiteList.some(pattern => isPathMatch(pattern, path))
}

router.beforeEach((to, from, next) => {
  NProgress.start()
  if (getToken()) {
    to.meta.title && useSettingsStore().setTitle(to.meta.title)
    /* has token*/
    if (to.path === '/login') {
      next({ path: '/' })
      NProgress.done()
    } else if (isWhiteList(to.path)) {
      next()
    } else {
      if (useUserStore().roles.length === 0) {
        isRelogin.show = true
        // 判断当前用户是否已拉取完user_info信息
        useUserStore().getInfo().then(() => {
          isRelogin.show = false
          usePermissionStore().generateRoutes().then(accessRoutes => {
            // 根据roles权限生成可访问的路由表
            accessRoutes.forEach(route => {
              if (!isHttp(route.path)) {
                router.addRoute(route) // 动态添加可访问路由表
              }
            })
            // 解决刷新404问题：如果目标路由在动态路由中，需要重新跳转
            if (to.matched.length === 0) {
                next({ ...to, replace: true })
            } else {
                next({ ...to, replace: true })
            }
          })
        }).catch(err => {
          useUserStore().logOut().then(() => {
            ElMessage.error(err)
            next({ path: '/' })
          })
        })
      } else {
        const loginType = useUserStore().loginType
        if (loginType === 'guest') {
          const blockedPaths = ['/hospital/appointment', '/hospital/record', '/user/profile']
          if (blockedPaths.some(p => to.path.startsWith(p))) {
            ElMessageBox.confirm('该页面需要登录后才能访问，是否立即登录？', '提示', {
              confirmButtonText: '去登录',
              cancelButtonText: '取消',
              type: 'warning'
            }).then(() => {
              useUserStore().logOut().then(() => {
                next(`/login?redirect=${to.fullPath}`)
              })
            }).catch(() => {
              NProgress.done()
              next(false)
            })
            return
          }
        }
        next()
      }
    }
  } else {
    // 没有token
    if (to.path === '/login' && !to.query.redirect && !to.query.logout) {
      // 显式且无重定向地访问登录页，默认走访客登录，进入首页
      useUserStore().loginGuest().then(() => {
        next({ path: '/index', replace: true })
      }).catch(() => {
        next()
      })
      NProgress.done()
    } else if (to.path === '/login' || to.path === '/register') {
      // 访问登录页(带redirect)或注册页，直接放行
      next()
    } else if (to.path === '/') {
      // 访问根目录，默认走访客登录，进入首页
      useUserStore().loginGuest().then(() => {
        next({ path: '/index', replace: true })
      }).catch(() => {
        next(`/login?redirect=${to.fullPath}`)
      })
      NProgress.done()
    } else if (to.path === '/index') {
      // 访问首页，如果没token则走访客登录
      useUserStore().loginGuest().then(() => {
        next({ path: '/index', replace: true })
      }).catch(() => {
        next(`/login?redirect=${to.fullPath}`)
      })
      NProgress.done()
    } else {
      // 访问其他页面，如果是白名单则放行，否则去登录页
      if (isWhiteList(to.path)) {
        next()
      } else {
        next(`/login?redirect=${to.fullPath}`)
        NProgress.done()
      }
    }
  }
})

router.afterEach(() => {
  NProgress.done()
})
