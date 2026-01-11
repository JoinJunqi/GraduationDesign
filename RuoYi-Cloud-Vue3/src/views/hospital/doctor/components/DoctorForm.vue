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
              <el-select v-model="form.deptId" placeholder="请选择科室" clearable style="width: 100%">
                <el-option
                  v-for="item in departmentOptions"
                  :key="item.id"
                  :label="item.name"
                  :value="item.id"
                />
              </el-select>
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
            <el-form-item label="登录密码" prop="password" v-if="!form.id">
              <el-input v-model="form.password" placeholder="请输入登录密码" type="password" show-password/>
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
              <el-select v-model="form.title" placeholder="请选择职称" clearable style="width: 100%">
                <el-option label="主任医师" value="主任医师" />
                <el-option label="副主任医师" value="副主任医师" />
                <el-option label="主治医师" value="主治医师" />
                <el-option label="住院医师" value="住院医师" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="状态" prop="isActive">
              <el-radio-group v-model="form.isActive">
                <el-radio :label="true">在职</el-radio>
                <el-radio :label="false">离职</el-radio>
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
import { listDepartment } from "@/api/hospital/department";
import { getCurrentInstance, ref, reactive, toRefs } from "vue";
import { useRoute, useRouter } from "vue-router";

const { proxy } = getCurrentInstance();
const route = useRoute();
const router = useRouter();

const departmentOptions = ref([]);

const data = reactive({
  form: {
    id: null,
    deptId: null,
    username: null,
    password: null,
    name: null,
    title: null,
    isActive: true
  },
  rules: {
    deptId: [
      { required: true, message: "所属科室不能为空", trigger: "change" }
    ],
    username: [
      { required: true, message: "登录账号不能为空", trigger: "blur" },
      { min: 4, max: 20, message: "账号长度必须在 4 到 20 个字符之间", trigger: "blur" }
    ],
    name: [
      { required: true, message: "姓名不能为空", trigger: "blur" }
    ],
    password: [
      { required: true, message: "密码不能为空", trigger: "blur" },
      { min: 6, max: 20, message: "密码长度必须在 6 到 20 个字符之间", trigger: "blur" }
    ],
    title: [
      { required: true, message: "职称不能为空", trigger: "change" }
    ]
  }
});

const { form, rules } = toRefs(data);

// 获取科室列表
function getDepartmentList() {
  listDepartment().then(response => {
    departmentOptions.value = response.rows;
  });
}

getDepartmentList();

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
