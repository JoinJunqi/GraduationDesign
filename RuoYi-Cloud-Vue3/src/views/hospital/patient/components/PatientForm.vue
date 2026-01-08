<template>
  <div class="app-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>{{ !form.id ? '添加患者' : '修改患者' }}</span>
          <el-button style="float: right; padding: 3px 0" type="text" @click="goBack">返回</el-button>
        </div>
      </template>
      
      <el-form ref="patientRef" :model="form" :rules="rules" label-width="100px">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="登录账号" prop="username">
              <el-input v-model="form.username" placeholder="请输入登录账号" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="登录密码" prop="passwordHash" v-if="!form.id">
              <el-input v-model="form.passwordHash" placeholder="请输入登录密码" type="password" show-password/>
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="姓名" prop="name">
              <el-input v-model="form.name" placeholder="请输入姓名" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="手机号" prop="phone">
              <el-input v-model="form.phone" placeholder="请输入手机号" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="身份证号" prop="idCard">
              <el-input v-model="form.idCard" placeholder="请输入身份证号" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-form-item>
          <el-button type="primary" @click="submitForm">确 定</el-button>
          <el-button @click="goBack">取 消</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup name="PatientForm">
import { getPatient, addPatient, updatePatient } from "@/api/hospital/patient";

const { proxy } = getCurrentInstance();
const route = useRoute();

const data = reactive({
  form: {
    id: null,
    username: null,
    passwordHash: null,
    name: null,
    phone: null,
    idCard: null
  },
  rules: {
    username: [
      { required: true, message: "登录账号不能为空", trigger: "blur" }
    ],
    name: [
      { required: true, message: "姓名不能为空", trigger: "blur" }
    ],
    passwordHash: [
      { required: true, message: "密码不能为空", trigger: "blur" }
    ],
    phone: [
      { required: true, message: "手机号不能为空", trigger: "blur" }
    ]
  }
});

const { form, rules } = toRefs(data);

// 获取参数
const patientId = route.params && route.params.id;

// 初始化数据
if (patientId) {
  getPatient(patientId).then(response => {
    form.value = response.data;
  });
}

function goBack() {
  const obj = { path: "/hospital/patient" };
  proxy.$tab.closeOpenPage(obj);
}

/** 提交按钮 */
function submitForm() {
  proxy.$refs["patientRef"].validate(valid => {
    if (valid) {
      if (form.value.id != null) {
        updatePatient(form.value).then(response => {
          proxy.$modal.msgSuccess("修改成功");
          goBack();
        });
      } else {
        addPatient(form.value).then(response => {
          proxy.$modal.msgSuccess("新增成功");
          goBack();
        });
      }
    }
  });
}
</script>
