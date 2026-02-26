<template>
   <div class="app-container">
      <el-row :gutter="20">
         <el-col :span="6" :xs="24">
            <el-card class="box-card">
               <template v-slot:header>
                 <div class="clearfix">
                   <span>{{ loginType === 'admin' ? '管理员信息' : '个人信息' }}</span>
                 </div>
               </template>
               <div>
                  <div class="text-center" v-if="loginType !== 'patient'">
                     <userAvatar />
                  </div>
                  <div class="text-center" v-else>
                     <img :src="userStore.avatar" class="img-circle img-lg" />
                  </div>
                  <ul class="list-group list-group-striped">
                     <li class="list-group-item">
                        <svg-icon icon-class="user" />用户名称
                        <div class="pull-right">{{ state.user.userName || state.user.username }}</div>
                     </li>
                     <li class="list-group-item" v-if="state.user.nickName || state.user.name">
                        <svg-icon icon-class="user" />{{ loginType === 'patient' ? '患者姓名' : '用户昵称' }}
                        <div class="pull-right">{{ state.user.nickName || state.user.name }}</div>
                     </li>
                     <li class="list-group-item">
                        <svg-icon icon-class="phone" />手机号码
                        <div class="pull-right">{{ state.user.phonenumber || state.user.phone }}</div>
                     </li>
                     <li class="list-group-item" v-if="state.user.idCard">
                        <svg-icon icon-class="post" />身份证号
                        <div class="pull-right">{{ state.user.idCard }}</div>
                     </li>
                     <li class="list-group-item" v-if="state.user.deptName">
                        <svg-icon icon-class="tree" />所属科室
                        <div class="pull-right">{{ state.user.deptName }}</div>
                     </li>
                     <li class="list-group-item" v-if="state.user.title">
                        <svg-icon icon-class="education" />职称
                        <div class="pull-right">{{ state.user.title }}</div>
                     </li>
                     <li class="list-group-item" v-if="state.user.dept">
                        <svg-icon icon-class="tree" />所属部门
                        <div class="pull-right">{{ state.user.dept.deptName }} / {{ state.roleGroup }}</div>
                     </li>
                     <li class="list-group-item" v-if="state.roleGroup && loginType !== 'patient'">
                        <svg-icon icon-class="peoples" />所属角色
                        <div class="pull-right">{{ state.roleGroup }}</div>
                     </li>
                     <li class="list-group-item">
                        <svg-icon icon-class="date" />创建日期
                        <div class="pull-right">{{ state.user.createTime || state.user.createdAt }}</div>
                     </li>
                  </ul>
               </div>
            </el-card>
         </el-col>
         <el-col :span="18" :xs="24">
            <el-card>
               <template v-slot:header>
                 <div class="clearfix">
                   <span>基本资料</span>
                 </div>
               </template>
               <el-tabs v-model="activeTab">
                  <el-tab-pane label="基本资料" name="userinfo">
                     <userInfo :user="state.user" @refresh="getUser" />
                  </el-tab-pane>
                  <el-tab-pane label="修改密码" name="resetPwd">
                     <resetPwd />
                  </el-tab-pane>
               </el-tabs>
            </el-card>
         </el-col>
      </el-row>
   </div>
</template>

<script setup name="Profile">
import { ref, reactive, onMounted, computed } from 'vue';
import userAvatar from "./userAvatar";
import userInfo from "./userInfo";
import resetPwd from "./resetPwd";
import { getUserProfile } from "@/api/system/user";
import useUserStore from "@/store/modules/user";

const userStore = useUserStore();
const activeTab = ref("userinfo");
const loginType = computed(() => userStore.loginType);
const state = reactive({
  user: {},
  roleGroup: "",
  postGroup: ""
});

function getUser() {
  getUserProfile().then(response => {
    const data = response.data;
    if (loginType.value === 'patient') {
      state.user = data.patient || data.user || data;
      state.roleGroup = "患者";
    } else if (loginType.value === 'doctor') {
      state.user = data.doctor || data.user || data;
      state.roleGroup = "医生";
    } else {
      state.user = data.user || data;
      state.roleGroup = data.roleGroup;
      state.postGroup = data.postGroup;
    }
  });
};

onMounted(() => {
  getUser();
});
</script>

<style lang="scss" scoped>
.img-circle {
  border-radius: 50%;
}

.img-lg {
  width: 120px;
  height: 120px;
}
</style>
