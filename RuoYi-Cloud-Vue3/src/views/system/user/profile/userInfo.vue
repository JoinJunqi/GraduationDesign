<template>
   <el-form ref="userRef" :model="form" :rules="rules" label-width="80px">
      <el-form-item :label="loginType === 'patient' ? '姓名' : '用户昵称'" :prop="loginType === 'patient' ? 'name' : 'nickName'">
         <el-input v-if="loginType === 'patient'" v-model="form.name" maxlength="30" />
         <el-input v-else v-model="form.nickName" maxlength="30" />
      </el-form-item>
      <el-form-item label="手机号码" :prop="loginType === 'patient' ? 'phone' : 'phonenumber'">
         <el-input v-if="loginType === 'patient'" v-model="form.phone" maxlength="11" />
         <el-input v-else v-model="form.phonenumber" maxlength="11" />
      </el-form-item>
      <el-form-item v-if="loginType === 'patient'" label="身份证号" prop="idCard">
         <el-input v-model="form.idCard" maxlength="18" />
      </el-form-item>
      <el-form-item v-if="loginType !== 'patient' && loginType !== 'admin'" label="性别">
         <el-radio-group v-model="form.sex">
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
import { getCurrentInstance, ref, computed, watch } from "vue";
import { updateUserProfile } from "@/api/system/user.js";
import { updatePatientProfile } from "@/api/hospital/patient.js";
import { updateDoctorProfile } from "@/api/hospital/doctor.js";
import useUserStore from "@/store/modules/user";

const props = defineProps({
  user: {
    type: Object
  }
});

const emit = defineEmits(["refresh"]);

const userStore = useUserStore();
const { proxy } = getCurrentInstance();
const loginType = computed(() => userStore.loginType);

const userRef = ref(null);
const form = ref({});

watch(() => props.user, (val) => {
  if (val) {
    form.value = { ...val };
  }
}, { immediate: true, deep: true });

const rules = ref({
  nickName: [{ required: true, message: "用户昵称不能为空", trigger: "blur" }],
  name: [{ required: true, message: "姓名不能为空", trigger: "blur" }],
  phonenumber: [{ required: true, message: "手机号码不能为空", trigger: "blur" }, { pattern: /^1[3|4|5|6|7|8|9][0-9]\d{8}$/, message: "请输入正确的手机号码", trigger: "blur" }],
  phone: [{ required: true, message: "手机号码不能为空", trigger: "blur" }, { pattern: /^1[3|4|5|6|7|8|9][0-9]\d{8}$/, message: "请输入正确的手机号码", trigger: "blur" }],
  idCard: [{ required: true, message: "身份证号不能为空", trigger: "blur" }, { pattern: /(^\d{15}$)|(^\d{18}$)|(^\d{17}(\d|X|x)$)/, message: "请输入正确的身份证号", trigger: "blur" }],
});

/** 提交按钮 */
function submit() {
  userRef.value.validate(valid => {
    if (valid) {
      let updateApi = updateUserProfile;
      if (loginType.value === 'patient') {
        updateApi = updatePatientProfile;
      } else if (loginType.value === 'doctor') {
        updateApi = updateDoctorProfile;
      }
      
      updateApi(form.value).then(response => {
        proxy.$modal.msgSuccess("修改成功");
        emit("refresh");
      });
    }
  });
};

/** 关闭按钮 */
function close() {
  proxy.$tab.closePage();
};
</script>
