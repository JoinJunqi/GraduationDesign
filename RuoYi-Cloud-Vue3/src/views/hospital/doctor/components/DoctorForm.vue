<template>
  <div class="app-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>{{ !form.id ? '添加医生' : '修改医生' }}</span>
          <el-button style="float: right; padding: 3px 0" type="text" @click="goBack">返回</el-button>
        </div>
      </template>
      
      <el-form ref="doctorRef" :model="form" :rules="rules" label-width="100px">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="所属科室" prop="deptId">
              <el-input v-model="form.deptId" placeholder="请输入科室ID" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="登录账号" prop="username">
              <el-input v-model="form.username" placeholder="请输入登录账号" />
            </el-form-item>
          </el-col>
        </el-row>
        
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="登录密码" prop="passwordHash" v-if="!form.id">
              <el-input v-model="form.passwordHash" placeholder="请输入登录密码" type="password" show-password/>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="姓名" prop="name">
              <el-input v-model="form.name" placeholder="请输入姓名" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="职称" prop="title">
              <el-input v-model="form.title" placeholder="请输入职称" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="状态" prop="isActive">
              <el-radio-group v-model="form.isActive">
                <el-radio :label="1">在职</el-radio>
                <el-radio :label="0">离职</el-radio>
              </el-radio-group>
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

<script setup name="DoctorForm">
import { getDoctor, addDoctor, updateDoctor } from "@/api/hospital/doctor";

const { proxy } = getCurrentInstance();
const route = useRoute();
const router = useRouter();

const data = reactive({
  form: {
    id: null,
    deptId: null,
    username: null,
    passwordHash: null,
    name: null,
    title: null,
    isActive: 1
  },
  rules: {
    deptId: [
      { required: true, message: "所属科室ID不能为空", trigger: "blur" }
    ],
    username: [
      { required: true, message: "登录账号不能为空", trigger: "blur" }
    ],
    name: [
      { required: true, message: "姓名不能为空", trigger: "blur" }
    ],
    passwordHash: [
      { required: true, message: "密码不能为空", trigger: "blur" }
    ]
  }
});

const { form, rules } = toRefs(data);

// 获取参数
const doctorId = route.params && route.params.id;

// 初始化数据
if (doctorId) {
  getDoctor(doctorId).then(response => {
    form.value = response.data;
  });
}

function goBack() {
  const obj = { path: "/hospital/doctor" };
  proxy.$tab.closeOpenPage(obj);
}

/** 提交按钮 */
function submitForm() {
  proxy.$refs["doctorRef"].validate(valid => {
    if (valid) {
      if (form.value.id != null) {
        updateDoctor(form.value).then(response => {
          proxy.$modal.msgSuccess("修改成功");
          goBack();
        });
      } else {
        addDoctor(form.value).then(response => {
          proxy.$modal.msgSuccess("新增成功");
          goBack();
        });
      }
    }
  });
}
</script>
