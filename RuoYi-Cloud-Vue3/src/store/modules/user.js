import router from '@/router'
import { ElMessageBox, } from 'element-plus'
import { login, loginPatient, loginDoctor, logout, getInfo } from '@/api/login'
import { getToken, setToken, removeToken } from '@/utils/auth'
import { isEmpty } from "@/utils/validate"
import defAva from '@/assets/images/profile.jpg'

const useUserStore = defineStore(
  'user',
  {
    state: () => ({
      token: getToken(),
      // loginType 是本项目前端区分三端能力的核心字段：admin / doctor / patient / guest
      loginType: localStorage.getItem('loginType') || 'admin',
      id: '',
      name: '',
      nickName: '',
      avatar: '',
      roles: [],
      permissions: [],
      adminLevel: 0,
      adminPermissions: 0
    }),
    actions: {
      setLoginType(type) {
        this.loginType = type;
        localStorage.setItem('loginType', type);
      },
      // 登录
      login(userInfo) {
        const username = userInfo.username.trim()
        const password = userInfo.password
        const code = userInfo.code
        const uuid = userInfo.uuid
        return new Promise((resolve, reject) => {
          login({ username, password, code, uuid }).then(res => {
            let data = res.data
            setToken(data.access_token)
            this.token = data.access_token
            this.setLoginType('admin')
            resolve()
          }).catch(error => {
            reject(error)
          })
        })
      },
      // 患者登录
      loginPatient(userInfo) {
        const username = userInfo.username.trim()
        const password = userInfo.password
        const code = userInfo.code
        const uuid = userInfo.uuid
        return new Promise((resolve, reject) => {
          loginPatient({ username, passwordHash: password, code, uuid }).then(res => {
            let data = res.data
            setToken(data.token)
            this.token = data.token
            this.setLoginType('patient')
            resolve()
          }).catch(error => {
            reject(error)
          })
        })
      },
      // 医生登录
      loginDoctor(userInfo) {
        const username = userInfo.username.trim()
        const password = userInfo.password
        const code = userInfo.code
        const uuid = userInfo.uuid
        return new Promise((resolve, reject) => {
          loginDoctor({ username, passwordHash: password, code, uuid }).then(res => {
            let data = res.data
            setToken(data.token)
            this.token = data.token
            this.setLoginType('doctor')
            resolve()
          }).catch(error => {
            reject(error)
          })
        })
      },
      // 访客登录
      loginGuest() {
        return new Promise((resolve) => {
          const token = 'GUEST_TOKEN'
          setToken(token)
          this.token = token
          this.setLoginType('guest')
          // 不要在这里设置 roles，留给 permission.js 里的 getInfo 去设置
          // this.roles = ['guest']
          this.name = '访客'
          this.nickName = '未登录'
          this.id = -1
          resolve()
        })
      },
      // 获取用户信息
      getInfo() {
        return new Promise((resolve, reject) => {
          if (this.loginType === 'guest') {
            // 访客不请求后端用户中心，前端本地构造最小权限集
            this.roles = ['guest']
            this.permissions = ['hospital:appointment:list', 'hospital:department:list', 'hospital:doctor:list', 'hospital:schedule:list']
            this.name = '访客'
            this.nickName = '未登录'
            this.avatar = defAva
            resolve({ roles: ['guest'], permissions: this.permissions })
            return
          }
          getInfo().then(res => {
            const data = res.data || res;
            let user = data.user || data.sysUser || data;
            
            // 针对患者和医生的特殊处理
            if (this.loginType === 'patient' && data.patient) {
                user = data.patient;
                user.avatar = ""; // 强制清空患者头像字段，使用默认图
            } else if (this.loginType === 'doctor' && data.doctor) {
                user = data.doctor;
            }
            
            const avatar = (isEmpty(user.avatar)) ? defAva : user.avatar
            
            // 患者/医生与管理员的数据结构不同，因此分支解析字段
            if (this.loginType === 'patient' || this.loginType === 'doctor') {
                this.roles = data.roles || ['ROLE_USER']
                this.permissions = data.permissions || ['*:*:*'] // 暂时给全部权限，后续细化
                this.id = user.id
                this.name = user.username || user.name
                this.nickName = user.name
            } else {
                if (data.roles && data.roles.length > 0) {
                  this.roles = data.roles
                  this.permissions = data.permissions
                } else {
                  this.roles = ['ROLE_DEFAULT']
                }
                this.id = user.userId || user.id
                this.name = user.userName || user.username
                this.nickName = user.nickName || user.name
                
                // 管理端额外维护“管理员级别 + 位运算权限”用于细粒度按钮控制
                this.adminLevel = parseInt(user.adminLevel || 0)
                this.adminPermissions = parseInt(user.permissions || 0)
            }
            
            this.avatar = avatar
            
            if(res.isDefaultModifyPwd) {
              ElMessageBox.confirm('您的密码还是初始密码，请修改密码！',  '安全提示', {  confirmButtonText: '确定',  cancelButtonText: '取消',  type: 'warning' }).then(() => {
                router.push({ name: 'Profile', params: { activeTab: 'resetPwd' } })
              }).catch(() => {})
            }
            if(!res.isDefaultModifyPwd && res.isPasswordExpired) {
              ElMessageBox.confirm('您的密码已过期，请尽快修改密码！',  '安全提示', {  confirmButtonText: '确定',  cancelButtonText: '取消',  type: 'warning' }).then(() => {
                router.push({ name: 'Profile', params: { activeTab: 'resetPwd' } })
              }).catch(() => {})
            }
            resolve(res)
          }).catch(error => {
            reject(error)
          })
        })
      },
      // 退出系统
      logOut() {
        return new Promise((resolve, reject) => {
          if (this.loginType === 'guest') {
            this.token = ''
            this.roles = []
            this.permissions = []
            removeToken()
            resolve()
            return
          }
          logout(this.token).then(() => {
            this.token = ''
            this.roles = []
            this.permissions = []
            removeToken()
            resolve()
          }).catch(error => {
            reject(error)
          })
        })
      }
    }
  })

export default useUserStore
