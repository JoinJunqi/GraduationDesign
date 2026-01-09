<template>
   <el-form ref="userRef" :model="user" :rules="rules" label-width="80px">
      <el-form-item :label="loginType === 'patient' ? '姓名' : '用户昵称'" :prop="loginType === 'patient' ? 'name' : 'nickName'">
         <el-input v-if="loginType === 'patient'" v-model="user.name" maxlength="30" />
         <el-input v-else v-model="user.nickName" maxlength="30" />
      </el-form-item>
      <el-form-item label="手机号码" :prop="loginType === 'patient' ? 'phone' : 'phonenumber'">
         <el-input v-if="loginType === 'patient'" v-model="user.phone" maxlength="11" />
         <el-input v-else v-model="user.phonenumber" maxlength="11" />
      </el-form-item>
      <el-form-item v-if="loginType === 'patient'" label="身份证号" prop="idCard">
         <el-input v-model="user.idCard" maxlength="18" />
      </el-form-item>
      <el-form-item v-if="loginType !== 'patient'" label="邮箱" prop="email">
         <el-input v-model="user.email" maxlength="50" />
      </el-form-item>
      <el-form-item v-if="loginType !== 'patient'" label="性别">
         <el-radio-group v-model="user.sex">
            <el-radio label="0">男</el-radio>
            <el-radio label="1">女</el-radio>
         </el-radio-group>
      </el-form-item>
      <el-form-item>
      <el-button type="primary" @click="submit">保存</el-button>
      <el-button type="danger" @click="close">关闭</el-button>
      </el-form-item>
   </el-form>
</template>

<script setup>
import { updateUserProfile } from "@/api/system/user";
import useUserStore from "@/store/modules/user";

const props = defineProps({
  user: {
    type: Object
  }
});

const userStore = useUserStore();
const { proxy } = getCurrentInstance();
const loginType = userStore.loginType;

const rules = ref({
  nickName: [{ required: true, message: "用户昵称不能为空", trigger: "blur" }],
  name: [{ required: true, message: "姓名不能为空", trigger: "blur" }],
  email: [{ required: true, message: "邮箱地址不能为空", trigger: "blur" }, { type: "email", message: "请输入正确的邮箱地址", trigger: ["blur", "change"] }],
  phonenumber: [{ required: true, message: "手机号码不能为空", trigger: "blur" }, { pattern: /^1[3|4|5|6|7|8|9][0-9]\d{8}$/, message: "请输入正确的手机号码", trigger: "blur" }],
  phone: [{ required: true, message: "手机号码不能为空", trigger: "blur" }, { pattern: /^1[3|4|5|6|7|8|9][0-9]\d{8}$/, message: "请输入正确的手机号码", trigger: "blur" }],
  idCard: [{ required: true, message: "身份证号不能为空", trigger: "blur" }, { pattern: /(^\d{15}$)|(^\d{18}$)|(^\d{17}(\d|X|x)$)/, message: "请输入正确的身份证号", trigger: "blur" }],
});

/** 提交按钮 */
function submit() {
  proxy.$refs.userRef.validate(valid => {
    if (valid) {
      updateUserProfile(props.user).then(response => {
        proxy.$modal.msgSuccess("修改成功");
      });
    }
  });
};

/** 关闭按钮 */
function close() {
  proxy.$tab.closePage();
};
</script>
