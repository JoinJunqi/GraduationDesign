<template>
  <div class="login">
    <el-form ref="loginRef" :model="loginForm" :rules="loginRules" class="login-form">
      <h3 class="title">{{ currentTitle }}</h3>
      
      <div style="text-align: center; margin-bottom: 20px;">
        <el-radio-group v-model="loginType" @change="handleTypeChange">
          <el-radio-button label="admin">管理员</el-radio-button>
          <el-radio-button label="patient">患者</el-radio-button>
          <el-radio-button label="doctor">医生</el-radio-button>
        </el-radio-group>
      </div>

      <el-form-item prop="username">
        <el-input
          v-model="loginForm.username"
          type="text"
          size="large"
          auto-complete="off"
          :placeholder="accountPlaceholder"
        >
          <template #prefix><svg-icon icon-class="user" class="el-input__icon input-icon" /></template>
        </el-input>
      </el-form-item>
      <el-form-item prop="password">
        <el-input
          v-model="loginForm.password"
          type="password"
          size="large"
          auto-complete="off"
          placeholder="密码"
          @keyup.enter="handleLogin"
        >
          <template #prefix><svg-icon icon-class="password" class="el-input__icon input-icon" /></template>
        </el-input>
      </el-form-item>
      <el-form-item prop="code" v-if="captchaEnabled">
        <el-input
          v-model="loginForm.code"
          size="large"
          auto-complete="off"
          placeholder="验证码"
          style="width: 63%"
          @keyup.enter="handleLogin"
        >
          <template #prefix><svg-icon icon-class="validCode" class="el-input__icon input-icon" /></template>
        </el-input>
        <div class="login-code">
          <img :src="codeUrl" @click="getCode" class="login-code-img"/>
        </div>
      </el-form-item>
      <el-checkbox v-model="loginForm.rememberMe" style="margin:0px 0px 25px 0px;">记住密码</el-checkbox>
      <el-form-item style="width:100%;">
        <el-button
          :loading="loading"
          size="large"
          type="primary"
          style="width:100%;"
          @click.prevent="handleLogin"
        >
          <span v-if="!loading">登 录</span>
          <span v-else>登 录 中...</span>
        </el-button>
        <div style="margin-top: 10px; text-align: right;" v-if="loginType === 'patient'">
          <router-link class="link-type" :to="'/register'">立即注册</router-link>
        </div>
      </el-form-item>
    </el-form>
    <!--  底部  -->
    <div class="el-login-footer">
      <span>Copyright © 2026 预约挂号系统 All Rights Reserved.</span>
    </div>
  </div>
</template>

<script setup>
import { getCodeImg } from "@/api/login"
import Cookies from "js-cookie"
import { encrypt, decrypt } from "@/utils/jsencrypt"
import useUserStore from '@/store/modules/user'
import useSettingsStore from '@/store/modules/settings'
import { loginPatient, loginDoctor } from "@/api/login" 

const userStore = useUserStore()
const route = useRoute()
const router = useRouter()
const { proxy } = getCurrentInstance()

// 登录类型管理
const loginType = ref(userStore.loginType || 'admin')
const currentTitle = ref('')
const accountPlaceholder = ref('账号')

function handleTypeChange(val) {
  userStore.setLoginType(val)
  updateUI(val)
}

function updateUI(type) {
  if (type === 'patient') {
    currentTitle.value = '患者登录'
    accountPlaceholder.value = '身份证号/手机号'
  } else if (type === 'doctor') {
    currentTitle.value = '医生登录'
    accountPlaceholder.value = '工号/用户名'
  } else {
    currentTitle.value = '管理员登录'
    accountPlaceholder.value = '账号'
  }
  useSettingsStore().setTitle(currentTitle.value)
}

// 初始化 UI
updateUI(loginType.value)

const loginForm = ref({
  username: loginType.value === 'admin' ? "admin" : "",
  password: loginType.value === 'admin' ? "admin123" : "",
  rememberMe: false,
  code: "",
  uuid: ""
})

const loginRules = computed(() => ({
  username: [{ required: true, trigger: "blur", message: "请输入您的账号" }],
  password: [{ required: true, trigger: "blur", message: "请输入您的密码" }],
  code: [{ required: captchaEnabled.value, trigger: "change", message: "请输入验证码" }]
}))

const codeUrl = ref("")
const loading = ref(false)
// 验证码开关
const captchaEnabled = ref(true)
const redirect = ref(undefined)

watch(route, (newRoute) => {
    redirect.value = newRoute.query && newRoute.query.redirect
}, { immediate: true })

function handleLogin() {
  proxy.$refs.loginRef.validate(valid => {
    if (valid) {
      loading.value = true
      if (loginForm.value.rememberMe) {
        Cookies.set("username", loginForm.value.username, { expires: 30 })
        Cookies.set("password", encrypt(loginForm.value.password), { expires: 30 })
        Cookies.set("rememberMe", loginForm.value.rememberMe, { expires: 30 })
      } else {
        Cookies.remove("username")
        Cookies.remove("password")
        Cookies.remove("rememberMe")
      }
      
      // 根据类型调用不同登录方法
      let loginPromise;
      if (loginType.value === 'patient') {
        loginPromise = userStore.loginPatient(loginForm.value)
      } else if (loginType.value === 'doctor') {
        loginPromise = userStore.loginDoctor(loginForm.value)
      } else {
        loginPromise = userStore.login(loginForm.value)
      }

      loginPromise.then(() => {
        const query = route.query
        const otherQueryParams = Object.keys(query).reduce((acc, cur) => {
          if (cur !== "redirect") {
            acc[cur] = query[cur]
          }
          return acc
        }, {})
        
        // 根据登录类型决定默认跳转页面
        let targetPath = redirect.value || "/";
        if (targetPath === "/" || targetPath === "/index") {
          if (loginType.value === 'patient') {
            targetPath = "/hospital/appointment";
          } else if (loginType.value === 'doctor') {
            targetPath = "/hospital/schedule";
          }
        }
        
        router.push({ path: targetPath, query: otherQueryParams })
      }).catch(() => {
        loading.value = false
        if (captchaEnabled.value) {
          getCode()
        }
      })
    }
  })
}

function getCode() {
  getCodeImg().then(res => {
    captchaEnabled.value = res.captchaEnabled === undefined ? true : res.captchaEnabled
    if (captchaEnabled.value) {
      codeUrl.value = "data:image/gif;base64," + res.img
      loginForm.value.uuid = res.uuid
    }
  })
}

function getCookie() {
  const username = Cookies.get("username")
  const password = Cookies.get("password")
  const rememberMe = Cookies.get("rememberMe")
  loginForm.value = {
    username: username === undefined ? loginForm.value.username : username,
    password: password === undefined ? loginForm.value.password : decrypt(password),
    rememberMe: rememberMe === undefined ? false : Boolean(rememberMe)
  }
}

getCode()
getCookie()
</script>

<style lang='scss' scoped>
.login {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100%;
  background-image: url("../assets/images/login-background.jpg");
  background-size: cover;
}
.title {
  margin: 0px auto 30px auto;
  text-align: center;
  color: #707070;
}

.login-form {
  border-radius: 6px;
  background: #ffffff;
  width: 400px;
  padding: 25px 25px 5px 25px;
  z-index: 1;
  .el-input {
    height: 40px;
    input {
      height: 40px;
    }
  }
  .input-icon {
    height: 39px;
    width: 14px;
    margin-left: 0px;
  }
}
.login-tip {
  font-size: 13px;
  text-align: center;
  color: #bfbfbf;
}
.login-code {
  width: 33%;
  height: 40px;
  float: right;
  img {
    cursor: pointer;
    vertical-align: middle;
  }
}
.el-login-footer {
  height: 40px;
  line-height: 40px;
  position: fixed;
  bottom: 0;
  width: 100%;
  text-align: center;
  color: #fff;
  font-family: Arial;
  font-size: 12px;
  letter-spacing: 1px;
}
.login-code-img {
  height: 40px;
  padding-left: 12px;
}
</style>
