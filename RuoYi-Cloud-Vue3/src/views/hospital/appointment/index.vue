<template>
  <div class="app-container">
    <el-row :gutter="20">
      <!-- 医生端日历选择 -->
      <el-col :span="6" v-if="isDoctor">
        <el-card shadow="hover" class="calendar-card">
          <template #header>
            <div class="card-header">
              <span>预约日历</span>
            </div>
          </template>
          <el-calendar v-model="calendarDate">
            <template #date-cell="{ data }">
              <div class="calendar-day" :class="{ 'is-selected': data.isSelected }">
                {{ data.day.split('-').slice(2).join('') }}
                <div class="dot" v-if="hasAppointment(data.day)"></div>
              </div>
            </template>
          </el-calendar>
        </el-card>
      </el-col>

      <el-col :span="isDoctor ? 18 : 24">
        <el-card shadow="hover">
          <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="68px">
            <el-form-item label="患者姓名" prop="patientName">
              <el-input
                v-model="queryParams.patientName"
                placeholder="请输入患者姓名"
                clearable
                @keyup.enter="handleQuery"
              />
            </el-form-item>
            <el-form-item label="医生姓名" prop="doctorName" v-if="!isDoctor">
              <el-autocomplete
                v-model="queryParams.doctorName"
                :fetch-suggestions="querySearchDoctor"
                clearable
                placeholder="请输入医生姓名"
                @select="handleQuery"
                @keyup.enter="handleQuery"
              >
                <template #default="{ item }">
                  <div class="doctor-suggestion">
                    <span class="name">{{ item.name }}</span>
                    <span class="dept" style="margin-left: 10px; color: #999; font-size: 12px;">{{ item.deptName }}</span>
                    <span class="title" style="margin-left: 10px; color: #999; font-size: 12px;">{{ item.title }}</span>
                  </div>
                </template>
              </el-autocomplete>
            </el-form-item>
            <el-form-item label="医生筛选" v-if="!isDoctor">
              <el-select v-model="queryParams.deptId" placeholder="选择科室" clearable @change="handleQueryDeptChange" style="width: 130px; margin-right: 5px;">
                <el-option
                  v-for="item in departmentList"
                  :key="item.id"
                  :label="item.name"
                  :value="item.id"
                />
              </el-select>
              <el-select v-model="queryParams.doctorId" placeholder="选择医生" clearable :disabled="!queryParams.deptId" @change="handleQuery" style="width: 130px;">
                <el-option
                  v-for="item in queryDoctorOptions"
                  :key="item.id"
                  :label="item.name"
                  :value="item.id"
                >
                  <span>{{ item.name }}</span>
                  <span style="float: right; color: #8492a6; font-size: 12px; margin-left: 10px;">{{ item.title }}</span>
                </el-option>
              </el-select>
            </el-form-item>
            <el-form-item label="状态" prop="status">
              <el-select v-model="queryParams.status" placeholder="请选择状态" clearable>
                <el-option label="待就诊" value="待就诊" />
                <el-option label="已取消" value="已取消" />
                <el-option label="已完成" value="已完成" />
                <el-option label="取消审核中" value="取消审核中" />
              </el-select>
            </el-form-item>
            <el-form-item label="就诊日期" prop="workDate">
              <el-date-picker
                v-model="queryParams.workDate"
                type="date"
                value-format="YYYY-MM-DD"
                placeholder="选择日期"
                clearable
                @change="handleQuery"
              />
            </el-form-item>
            <el-form-item>
              <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
              <el-button icon="Refresh" @click="resetQuery">重置</el-button>
            </el-form-item>
          </el-form>

          <el-row :gutter="10" class="mb8">
            <el-col :span="1.5">
              <el-button
                type="primary"
                plain
                icon="Plus"
                @click="handleRegister"
                v-if="isPatient"
              >预约挂号</el-button>
            </el-col>
            <el-col :span="1.5" v-if="hasAdminPermi(AdminPermi.BOOKING)">
              <el-button
                type="success"
                plain
                icon="Edit"
                :disabled="single"
                @click="handleUpdate"
                v-if="!isPatient"
                v-hasPermi="['hospital:appointment:edit']"
              >修改</el-button>
            </el-col>
            <el-col :span="1.5" v-if="hasAdminPermi(AdminPermi.BOOKING)">
              <el-button
                type="danger"
                plain
                icon="Delete"
                :disabled="multiple"
                @click="handleDelete"
                v-if="!isPatient"
                v-hasPermi="['hospital:appointment:remove']"
              >删除</el-button>
            </el-col>
            <el-col :span="1.5" v-if="hasAdminPermi(AdminPermi.BOOKING)">
              <el-button
                type="warning"
                plain
                icon="DeleteFilled"
                @click="handleRecycle"
                v-if="isAdmin"
                v-hasPermi="['hospital:appointment:remove']"
              >回收站</el-button>
            </el-col>
            <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
          </el-row>

          <el-table v-loading="loading" :data="appointmentList" @selection-change="handleSelectionChange" @sort-change="handleSortChange" :row-class-name="tableRowClassName">
            <el-table-column type="selection" width="55" align="center" />
            <el-table-column label="患者姓名" align="center" prop="patientName" sortable="custom" />
            <el-table-column label="医生" align="center" prop="doctorName" sortable="custom" />
            <el-table-column label="职称" align="center" prop="title" />
            <el-table-column label="就诊日期" align="center" prop="workDate" sortable="custom">
              <template #default="scope">
                <span>{{ parseTime(scope.row.workDate, '{y}-{m}-{d}') }}</span>
              </template>
            </el-table-column>
            <el-table-column label="班次" align="center" prop="timeSlot" />
            <el-table-column label="状态" align="center" prop="status" sortable="custom">
              <template #default="scope">
                <el-tag :type="scope.row.status === '已完成' ? 'success' : (scope.row.status === '已取消' ? 'info' : (scope.row.status === '取消审核中' ? 'danger' : 'warning'))">
                  {{ scope.row.status }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column label="预约时间" align="center" prop="bookedAt" width="160" sortable="custom">
              <template #default="scope">
                <span>{{ parseTime(scope.row.bookedAt) }}</span>
              </template>
            </el-table-column>
            <el-table-column label="预约时段" align="center" prop="appointmentTime" width="100" />
            <el-table-column label="操作" align="center" class-name="small-padding fixed-width" width="200">
              <template #default="scope">
                <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-if="isAdmin && hasAdminPermi(AdminPermi.BOOKING)" v-hasPermi="['hospital:appointment:edit']">修改</el-button>
                
                <!-- 患者端操作 -->
                <el-button link type="danger" icon="CircleClose" @click="handleRequestCancel(scope.row)" v-if="isPatient && scope.row.status === '待就诊'">取消预约</el-button>
                
                <!-- 医生端操作 -->
                <template v-if="isDoctor">
                  <el-button link type="success" icon="VideoPlay" @click="handleStartConsultation(scope.row)" v-if="scope.row.status === '待就诊'">开始就诊</el-button>
                  <el-button link type="danger" icon="MessageBox" @click="handleRequestCancel(scope.row)" v-if="scope.row.status === '待就诊'">申请取消</el-button>
                </template>

                <!-- 审核中状态的操作 (撤销申请) -->
                <template v-if="scope.row.status === '取消审核中'">
                  <el-button link type="primary" icon="RefreshLeft" @click="handleRevokeRequest(scope.row)">撤回申请</el-button>
                </template>

                <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)" v-if="isAdmin && hasAdminPermi(AdminPermi.BOOKING)" v-hasPermi="['hospital:appointment:remove']">删除</el-button>
              </template>
            </el-table-column>
          </el-table>"}]}
          
          <pagination
            v-show="total > 0"
            :total="total"
            v-model:page="queryParams.pageNum"
            v-model:limit="queryParams.pageSize"
            @pagination="getList"
          />
        </el-card>
      </el-col>
    </el-row>
    
    <!-- 添加或修改预约对话框 -->
    <el-dialog :title="title" v-model="open" width="500px" append-to-body>
      <el-form ref="appointmentRef" :model="form" :rules="rules" label-width="80px">
        <el-form-item label="患者ID" prop="patientId">
          <el-input v-model="form.patientId" placeholder="请输入患者ID" />
        </el-form-item>
        <el-form-item label="排班ID" prop="scheduleId">
          <el-input v-model="form.scheduleId" placeholder="请输入排班ID" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-select v-model="form.status" placeholder="请选择状态">
            <el-option label="待就诊" value="待就诊" />
            <el-option label="已取消" value="已取消" />
            <el-option label="已完成" value="已完成" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="submitForm">确 定</el-button>
          <el-button @click="cancel">取 消</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="Appointment">
import { ref, reactive, toRefs, getCurrentInstance, computed, onMounted, onUnmounted, watch } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { listAppointment, getAppointment, delAppointment, addAppointment, updateAppointment, cancelAppointment, requestCancel, cancelRequest } from "@/api/hospital/appointment.js";
import { listDepartment } from "@/api/hospital/department";
import { listDoctorByDept, listDoctor } from "@/api/hospital/doctor";
import { parseTime } from "@/utils/ruoyi";
import useUserStore from "@/store/modules/user";
import { hasAdminPermi, AdminPermi } from "@/utils/adminPermi";
import { ElNotification } from 'element-plus';

const { proxy } = getCurrentInstance();
const userStore = useUserStore();
const route = useRoute();
const router = useRouter();
const loginType = computed(() => userStore.loginType);
const isPatient = computed(() => loginType.value === 'patient');
const isDoctor = computed(() => loginType.value === 'doctor');
const isAdmin = computed(() => loginType.value === 'admin' || userStore.roles.includes('admin'));

const appointmentList = ref([]);
const open = ref(false);
const loading = ref(true);
const showSearch = ref(true);
const ids = ref([]);
const single = ref(true);
const multiple = ref(true);
const total = ref(0);
const title = ref("");
const newAppointmentId = ref(null);
const calendarDate = ref(new Date());
const departmentList = ref([]);
const queryDoctorOptions = ref([]);

/** 监听日历日期变化 */
watch(calendarDate, (newDate) => {
  if (newDate) {
    queryParams.value.workDate = parseTime(newDate, '{y}-{m}-{d}');
    handleQuery();
  }
});

/** 判断某天是否有预约 (简化逻辑，实际可从后端获取有预约的日期列表) */
function hasAppointment(day) {
  // 这里可以根据已加载的列表或者额外API判断
  return appointmentList.value.some(item => parseTime(item.workDate, '{y}-{m}-{d}') === day);
}

/** 开始就诊 */
function handleStartConsultation(row) {
  router.push({
    path: '/hospital/consultation/index',
    query: {
      appointmentId: row.id
    }
  });
}

const data = reactive({
  form: {},
  queryParams: {
    pageNum: 1,
    pageSize: 10,
    patientName: null,
    doctorName: null,
    deptId: null,
    doctorId: null,
    status: null,
    workDate: null,
    orderByColumn: "bookedAt",
    isAsc: "descending",
    params: {}
  },
  rules: {
    patientId: [
      { required: true, message: "患者ID不能为空", trigger: "blur" }
    ],
    scheduleId: [
      { required: true, message: "排班ID不能为空", trigger: "blur" }
    ]
  }
});

const { queryParams, form, rules } = toRefs(data);

/** 跳转到挂号页面 */
function handleRegister() {
  router.push({ path: '/hospital/register' });
}

/** 监听路由参数变化，处理新预约提醒点击跳转 */
watch(() => route.query.newId, (newId) => {
  if (newId) {
    newAppointmentId.value = parseInt(newId);
    resetQuery();
    
    // 5秒后移除高亮
    setTimeout(() => {
      newAppointmentId.value = null;
    }, 5000);
  }
}, { immediate: true });

/** 查询科室列表 */
function getDepartmentList() {
  listDepartment().then(response => {
    departmentList.value = response.rows;
  });
}

/** 医生姓名输入建议 */
function querySearchDoctor(queryString, cb) {
  if (queryString) {
    listDoctor({ name: queryString }).then(response => {
      const results = response.rows.map(item => {
        return {
          value: item.name,
          name: item.name,
          deptName: item.deptName,
          title: item.title
        };
      });
      cb(results);
    });
  } else {
    cb([]);
  }
}

/** 搜索栏科室变更加载医生列表 */
function handleQueryDeptChange(deptId) {
  queryParams.value.doctorId = null;
  queryDoctorOptions.value = [];
  if (deptId) {
    listDoctorByDept(deptId).then(response => {
      queryDoctorOptions.value = response.data;
    });
  }
  handleQuery();
}

/** 排序触发事件 */
function handleSortChange(column) {
  queryParams.value.orderByColumn = column.prop;
  queryParams.value.isAsc = column.order;
  getList();
}

function getList() {
  loading.value = true;
  listAppointment(queryParams.value).then(response => {
    appointmentList.value = response.rows;
    total.value = response.total;
    loading.value = false;
  }).catch(error => {
    console.error("Failed to fetch appointments:", error);
    loading.value = false;
  });
}

/** 表格行样式：用于闪烁提醒 */
function tableRowClassName({ row }) {
  if (row.id === newAppointmentId.value) {
    return 'new-appointment-row';
  }
  return '';
}

onMounted(() => {
  getDepartmentList();
  // 如果是医生且没有特定ID查询，默认显示今天的预约
  if (isDoctor.value && !route.query.newId && !queryParams.value.workDate) {
    queryParams.value.workDate = parseTime(new Date(), '{y}-{m}-{d}');
  }
  getList();
});

/** 取消按钮 */
function cancel() {
  open.value = false;
  reset();
}

/** 表单重置 */
function reset() {
  form.value = {
    id: null,
    patientId: null,
    scheduleId: null,
    status: '待就诊'
  };
  proxy.resetForm("appointmentRef");
}

/** 搜索按钮操作 */
function handleQuery() {
  getList();
}

/** 重置按钮操作 */
function resetQuery() {
  queryDoctorOptions.value = [];
  proxy.resetForm("queryRef");
  handleQuery();
}

/** 多选框选中数据 */
function handleSelectionChange(selection) {
  ids.value = selection.map(item => item.id);
  single.value = selection.length != 1;
  multiple.value = !selection.length;
}

/** 新增按钮操作 */
function handleAdd() {
  reset();
  open.value = true;
  title.value = "添加预约";
}

/** 修改按钮操作 */
function handleUpdate(row) {
  reset();
  const id = row.id || ids.value;
  getAppointment(id).then(response => {
    form.value = response.data;
    open.value = true;
    title.value = "修改预约";
  });
}

/** 提交按钮 */
function submitForm() {
  proxy.$refs["appointmentRef"].validate(valid => {
    if (valid) {
      if (form.value.id != null) {
        updateAppointment(form.value).then(response => {
          proxy.$modal.msgSuccess("修改成功");
          open.value = false;
          getList();
        });
      } else {
        addAppointment(form.value).then(response => {
          proxy.$modal.msgSuccess("新增成功");
          open.value = false;
          getList();
        });
      }
    }
  });
}

/** 发起取消申请 (患者/医生均需审核) */
function handleRequestCancel(row) {
  const id = row.id;
  proxy.$prompt('请输入取消原因', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    inputPattern: /\S+/,
    inputErrorMessage: '原因不能为空'
  }).then(({ value }) => {
    // 构造审核申请数据
    const auditData = {
      auditType: 'APPOINTMENT_CANCEL',
      targetId: id,
      requestReason: value
    };
    // 这里我们可以直接调用我们新写的 audit.js 中的接口，或者通过 appointment.js 转发
    // 为了简单起见，我直接在这里导入并使用 submitAudit
    import("@/api/hospital/audit").then(module => {
      module.submitAudit(auditData).then(response => {
        getList();
        proxy.$modal.msgSuccess("取消申请已提交，请等待管理员审核");
      });
    });
  }).catch(() => {});
}

/** 撤销取消申请 */
function handleRevokeRequest(row) {
  proxy.$modal.confirm('确认撤销取消预约申请吗？').then(function() {
    return cancelRequest(row.id);
  }).then(() => {
    getList();
    proxy.$modal.msgSuccess("撤销成功");
  }).catch(() => {});
}

/** 删除按钮操作 */
function handleDelete(row) {
  const _ids = row.id || ids.value;
  proxy.$modal.confirm('是否确认删除预约编号为"' + _ids + '"的数据项？').then(function() {
    return delAppointment(_ids);
  }).then(() => {
    getList();
    proxy.$modal.msgSuccess("删除成功");
  }).catch(() => {});
}

/** 跳转到回收站 */
function handleRecycle() {
  router.push("/hospital/recycle/appointment");
}
</script>

<style scoped>
.calendar-card {
  height: 100%;
}

.calendar-day {
  height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  position: relative;
}

.calendar-day.is-selected {
  color: #409eff;
  font-weight: bold;
}

.dot {
  width: 6px;
  height: 6px;
  background-color: #f56c6c;
  border-radius: 50%;
  position: absolute;
  bottom: 2px;
}

.new-appointment-row {
  animation: flash-animation 2s ease-in-out infinite;
  background-color: #fdf6ec !important;
}

@keyframes flash-animation {
  0% { background-color: #fdf6ec; }
  50% { background-color: #faecd8; }
  100% { background-color: #fdf6ec; }
}

:deep(.el-calendar-table .el-calendar-day) {
  height: 60px;
  padding: 0;
}

:deep(.el-calendar__header) {
  padding: 10px 20px;
}

:deep(.el-calendar__body) {
  padding: 10px;
}
</style>
