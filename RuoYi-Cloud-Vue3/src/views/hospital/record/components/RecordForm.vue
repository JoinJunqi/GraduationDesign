<template>
  <div class="app-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>{{ !form.id ? '添加病历' : '修改病历' }}</span>
          <el-button style="float: right; padding: 3px 0" type="text" @click="goBack">返回</el-button>
        </div>
      </template>
      
      <el-form ref="recordRef" :model="form" :rules="rules" label-width="100px">
        <el-row :gutter="20">
          <el-col :span="8">
            <el-form-item label="预约ID" prop="appointmentId">
              <el-input v-model="form.appointmentId" placeholder="请输入预约ID" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="患者ID" prop="patientId">
              <el-input v-model="form.patientId" placeholder="请输入患者ID" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="医生ID" prop="doctorId">
              <el-input v-model="form.doctorId" placeholder="请输入医生ID" />
            </el-form-item>
          </el-col>
        </el-row>
        
        <el-form-item label="诊断结果" prop="diagnosis">
          <el-input v-model="form.diagnosis" type="textarea" :rows="3" placeholder="请输入诊断结果" />
        </el-form-item>
        
        <el-form-item label="处方信息" prop="prescription">
          <el-input v-model="form.prescription" type="textarea" :rows="4" placeholder="请输入处方信息" />
        </el-form-item>
        
        <el-form-item label="医嘱备注" prop="notes">
          <el-input v-model="form.notes" type="textarea" :rows="3" placeholder="请输入医嘱备注" />
        </el-form-item>
        
        <el-form-item label="就诊时间" prop="visitTime">
          <el-date-picker
            v-model="form.visitTime"
            type="datetime"
            placeholder="选择就诊时间"
            value-format="YYYY-MM-DD HH:mm:ss"
          />
        </el-form-item>

        <el-form-item>
          <el-button type="primary" @click="submitForm">确 定</el-button>
          <el-button @click="goBack">取 消</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup name="RecordForm">
import { ref, reactive, toRefs, getCurrentInstance, onMounted } from 'vue';
import { useRoute } from 'vue-router';
import { getRecord, addRecord, updateRecord } from "@/api/hospital/record.js";

const { proxy } = getCurrentInstance();
const route = useRoute();

const data = reactive({
  form: {
    id: null,
    appointmentId: null,
    patientId: null,
    doctorId: null,
    diagnosis: null,
    prescription: null,
    notes: null,
    visitTime: null
  },
  rules: {
    appointmentId: [
      { required: true, message: "预约ID不能为空", trigger: "blur" }
    ],
    patientId: [
      { required: true, message: "患者ID不能为空", trigger: "blur" }
    ],
    doctorId: [
      { required: true, message: "医生ID不能为空", trigger: "blur" }
    ],
    diagnosis: [
      { required: true, message: "诊断结果不能为空", trigger: "blur" }
    ],
    visitTime: [
      { required: true, message: "就诊时间不能为空", trigger: "blur" }
    ]
  }
});

const { form, rules } = toRefs(data);

// 获取参数
const recordId = route.params && route.params.id;

// 初始化数据
if (recordId) {
  getRecord(recordId).then(response => {
    form.value = response.data;
  });
}

function goBack() {
  const obj = { path: "/hospital/record" };
  proxy.$tab.closeOpenPage(obj);
}

/** 提交按钮 */
function submitForm() {
  proxy.$refs["recordRef"].validate(valid => {
    if (valid) {
      if (form.value.id != null) {
        updateRecord(form.value).then(response => {
          proxy.$modal.msgSuccess("修改成功");
          goBack();
        });
      } else {
        addRecord(form.value).then(response => {
          proxy.$modal.msgSuccess("新增成功");
          goBack();
        });
      }
    }
  });
}
</script>
