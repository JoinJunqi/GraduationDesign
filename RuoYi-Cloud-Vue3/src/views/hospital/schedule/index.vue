<template>
  <div class="app-container">
    <el-row :gutter="20">
      <!-- 左侧日历 -->
      <el-col :xs="24" :sm="24" :md="6" v-if="!isDoctor" class="calendar-col">
        <el-card shadow="never">
          <template #header>
            <div class="card-header">
              <span>日期选择</span>
            </div>
          </template>
          <el-calendar v-model="selectedDate" class="mini-calendar">
            <template #date-cell="{ data }">
              <div class="calendar-cell" @click="handleDateClick(data.day)">
                {{ data.day.split('-').slice(2).join('') }}
              </div>
            </template>
          </el-calendar>
        </el-card>
      </el-col>

      <!-- 右侧列表 -->
      <el-col :xs="24" :sm="24" :md="isDoctor ? 24 : 18" class="list-col">
        <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="68px">
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
        <el-select v-model="queryParams.deptId" placeholder="选择科室" clearable @change="handleQueryDeptChange" class="filter-select filter-select-dept">
          <el-option
            v-for="item in departmentList"
            :key="item.id"
            :label="item.name"
            :value="item.id"
          />
        </el-select>
        <el-select v-model="queryParams.doctorId" placeholder="选择医生" clearable :disabled="!queryParams.deptId" @change="handleQuery" class="filter-select">
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
      <el-form-item label="医生职称" prop="title" v-if="!isDoctor">
        <el-input
          v-model="queryParams.title"
          placeholder="请输入职称"
          clearable
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="出诊日期" prop="workDate">
        <el-date-picker
          v-model="queryParams.workDate"
          type="date"
          placeholder="选择日期"
          value-format="YYYY-MM-DD"
          clearable
        />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8" v-if="(isAdmin && hasAdminPermi(AdminPermi.SCHEDULE)) || isDoctor">
      <el-col :span="1.5">
        <el-button
          type="primary"
          plain
          icon="Plus"
          @click="handleAdd"
          v-hasPermi="['hospital:schedule:add']"
        >新增</el-button>
      </el-col>
      <el-col :span="1.5" v-if="!isDoctor">
        <el-button
          type="success"
          plain
          icon="Edit"
          :disabled="single"
          @click="handleUpdate"
          v-hasPermi="['hospital:schedule:edit']"
        >修改</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="danger"
          plain
          icon="Delete"
          :disabled="multiple"
          @click="handleDelete"
          v-hasPermi="['hospital:schedule:remove']"
        >{{ isDoctor ? '申请删除' : '删除' }}</el-button>
        <span v-if="isDoctor" style="margin-left: 10px; font-size: 12px; color: #909399;">仅可申请删除未来且已取消排班</span>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="warning"
          plain
          icon="DeleteFilled"
          @click="handleRecycle"
          v-hasPermi="['hospital:schedule:remove']"
        >回收站</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="scheduleList" @selection-change="handleSelectionChange" @sort-change="handleSortChange">
      <el-table-column type="selection" width="55" align="center" :selectable="isRowSelectable" />
      <el-table-column label="出诊日期" align="center" prop="workDate" width="120" sortable="custom">
        <template #default="scope">
          <span>{{ parseTime(scope.row.workDate, '{y}-{m}-{d}') }}</span>
        </template>
      </el-table-column>
      <el-table-column label="科室" align="center" prop="deptName" />
      <el-table-column label="医生" align="center" prop="doctorName" sortable="custom" />
      <el-table-column label="职称" align="center" prop="title" />
      <el-table-column label="班次" align="center" prop="timeSlot" sortable="custom" />
      <el-table-column label="总号源" align="center" prop="totalCapacity" sortable="custom" />
      <el-table-column label="剩余号源" align="center" prop="availableSlots" sortable="custom" />
      <el-table-column label="状态" align="center" prop="status">
        <template #default="scope">
          <el-tag v-if="scope.row.status === 0" type="success">正常</el-tag>
          <el-tag v-else-if="scope.row.status === 1" type="warning">有调整</el-tag>
          <el-tag v-else-if="scope.row.status === 2" type="danger">已取消</el-tag>
          <el-tag v-else-if="scope.row.status === 3" type="warning">待审核</el-tag>
          <el-tag v-else-if="scope.row.status === 4" type="danger">申请删除</el-tag>
          <el-tag v-else-if="scope.row.status === 5" type="danger">已驳回</el-tag>
          <el-tag v-else type="info">未知</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width" v-if="(isAdmin && hasAdminPermi(AdminPermi.SCHEDULE)) || isDoctor">
        <template #default="scope">
          <template v-if="!shouldHideDoctorRowActions(scope.row)">
            <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['hospital:schedule:edit']">修改</el-button>
            <el-button link type="primary" icon="CircleClose" @click="handleCancelSchedule(scope.row)" v-if="scope.row.status !== 2 && scope.row.status !== 3 && scope.row.status !== 4" v-hasPermi="['hospital:schedule:edit']">取消</el-button>
            <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)" v-if="!isDoctor" v-hasPermi="['hospital:schedule:remove']">删除</el-button>
          </template>
        </template>
      </el-table-column>
    </el-table>

    <pagination
      v-show="total > 0"
      :total="total"
      v-model:page="queryParams.pageNum"
      v-model:limit="queryParams.pageSize"
      @pagination="getList"
    />
    </el-col>
    </el-row>
    
    <!-- 添加或修改排班对话框 -->
    <el-dialog :title="title" v-model="open" :width="dialogWidth" :top="dialogTop" append-to-body>
      <el-form ref="scheduleRef" :model="form" :rules="rules" label-width="80px">
    <template v-if="isDoctor">
      <el-form-item label="医生" prop="doctorName">
        <el-input v-model="form.doctorName" placeholder="医生姓名" :disabled="true" />
      </el-form-item>
    </template>
    <template v-else>
      <!-- 修改模式：显示只读的科室和医生名称 -->
      <template v-if="form.id">
        <el-form-item label="科室">
          <el-input v-model="form.deptName" disabled />
        </el-form-item>
        <el-form-item label="医生">
          <el-input v-model="form.doctorName" disabled />
        </el-form-item>
      </template>
      <!-- 新增模式：显示选择框 -->
      <template v-else>
        <el-form-item label="科室" prop="deptId">
          <el-select v-model="form.deptId" placeholder="请选择科室" @change="handleDeptChange" filterable style="width: 100%">
            <el-option
              v-for="item in departmentList"
              :key="item.id"
              :label="item.name"
              :value="item.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="医生" prop="doctorId">
          <el-select v-model="form.doctorId" placeholder="请选择医生" :disabled="!form.deptId" filterable style="width: 100%">
            <el-option
              v-for="item in doctorOptions"
              :key="item.id"
              :label="item.name"
              :value="item.id"
            >
              <span>{{ item.name }}</span>
              <span style="float: right; color: #8492a6; font-size: 12px; margin-left: 10px;">{{ item.title }}</span>
            </el-option>
          </el-select>
        </el-form-item>
      </template>
    </template>
        <el-form-item label="出诊日期" prop="workDate">
          <el-tooltip
            effect="dark"
            content="已过当天的可修改时间"
            placement="top"
            :disabled="!isEditDisabled"
          >
            <div style="width: 100%">
              <el-date-picker
                v-model="form.workDate"
                type="date"
                placeholder="选择出诊日期"
                value-format="YYYY-MM-DD"
                @change="handleWorkDateChange"
                :disabled="isEditDisabled"
                style="width: 100%"
              />
            </div>
          </el-tooltip>
        </el-form-item>
        <el-form-item label="班次" prop="timeSlot">
          <el-tooltip
            effect="dark"
            content="已过当天的可修改时间"
            placement="top"
            :disabled="!isEditDisabled"
          >
            <div style="width: 100%">
              <el-select 
                v-model="form.timeSlot" 
                placeholder="请选择班次" 
                @change="handleTimeSlotChange"
                :disabled="isEditDisabled"
                style="width: 100%"
              >
                <el-option label="上午" value="上午" />
                <el-option label="下午" value="下午" />
                <el-option label="全天" value="全天" />
              </el-select>
            </div>
          </el-tooltip>
        </el-form-item>
        <el-form-item label="总号源" prop="totalCapacity">
          <el-tooltip
            effect="dark"
            content="已过当天的可修改时间"
            placement="top"
            :disabled="!isEditDisabled"
          >
            <div style="width: 100%">
              <el-input-number 
                v-model="form.totalCapacity" 
                :min="1" 
                :max="form.maxCapacity || 28" 
                :disabled="isEditDisabled"
              />
            </div>
          </el-tooltip>
          <div class="help-block" style="font-size: 12px; color: #909399;">
            按15分钟/号计算，该时段上限为 {{ form.maxCapacity || 28 }} 个号
          </div>
        </el-form-item>
        <el-form-item label="剩余号源" prop="availableSlots" v-if="form.id">
          <el-input-number v-model="form.availableSlots" :min="0" :disabled="true" />
        </el-form-item>
        <el-form-item label="状态" prop="status" v-if="form.id && !isDoctor">
          <el-radio-group v-model="form.status">
            <el-radio :label="0">正常</el-radio>
            <el-radio :label="1">有调整</el-radio>
            <el-radio :label="2">已取消</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="submitForm" :disabled="isEditDisabled">确 定</el-button>
          <el-button @click="cancel">取 消</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="Schedule">
import { ref, reactive, toRefs, computed, getCurrentInstance, onMounted, onActivated } from 'vue';
import { useWindowSize } from '@vueuse/core'
import { listSchedule, getSchedule, delSchedule, addSchedule, updateSchedule } from "@/api/hospital/schedule";
import { listDepartment } from "@/api/hospital/department";
import { listDoctorByDept, listDoctor } from "@/api/hospital/doctor";
import useUserStore from "@/store/modules/user";
import { useRouter } from 'vue-router';
import { hasAdminPermi, AdminPermi } from "@/utils/adminPermi";

const userStore = useUserStore();
const { proxy } = getCurrentInstance();
const { parseTime } = proxy;
const router = useRouter();

const isDoctor = computed(() => userStore.roles.includes('doctor'));
const isAdmin = computed(() => userStore.loginType === 'admin');
const isPatient = computed(() => userStore.roles.includes('patient'));
const currentDoctorName = computed(() => userStore.nickName);
const currentDoctorId = computed(() => userStore.id);
const isEditDisabled = ref(false);
const { width } = useWindowSize()
const isMobile = computed(() => width.value <= 768)
const dialogWidth = computed(() => (isMobile.value ? '92%' : '500px'))
const dialogTop = computed(() => (isMobile.value ? '4vh' : '15vh'))

const scheduleList = ref([]);
const open = ref(false);
const loading = ref(true);
const showSearch = ref(true);
const ids = ref([]);
const single = ref(true);
const multiple = ref(true);
const title = ref("");
const total = ref(0);
const selectedDate = ref(new Date());
const originalTotalCapacity = ref(0);
const originalTimeSlot = ref("");
const departmentList = ref([]);
const doctorOptions = ref([]);
const queryDoctorOptions = ref([]);

const data = reactive({
  form: {},
  queryParams: {
    pageNum: 1,
    pageSize: 10,
    doctorName: null,
    deptId: null,
    doctorId: null,
    title: null,
    workDate: null,
    orderByColumn: "workDate",
    isAsc: "descending",
    params: {
      includeDeleted: "false"
    }
  }
});

const { queryParams, form } = toRefs(data);

const rules = computed(() => {
  const baseRules = {
    workDate: [
      { required: true, message: "出诊日期不能为空", trigger: "blur" }
    ],
    timeSlot: [
      { required: true, message: "班次不能为空", trigger: "change" }
    ],
    totalCapacity: [
      { required: true, message: "总号源数不能为空", trigger: "blur" }
    ]
  };

  if (isDoctor.value) {
    return {
      ...baseRules,
      doctorName: [
        { required: true, message: "医生姓名不能为空", trigger: "blur" }
      ]
    };
  } else {
    return {
      ...baseRules,
      deptId: [
        { required: true, message: "科室不能为空", trigger: "change" }
      ],
      doctorId: [
        { required: true, message: "医生不能为空", trigger: "change" }
      ]
    };
  }
});

onMounted(() => {
  if (!isDoctor.value) {
    queryParams.value.workDate = parseTime(new Date(), '{y}-{m}-{d}');
  }
  getList();
  getDepartmentList();
});

onActivated(() => {
  getList();
});

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

/** 排序触发事件 */
function handleSortChange(column) {
  queryParams.value.orderByColumn = column.prop;
  queryParams.value.isAsc = column.order;
  getList();
}

/** 计算号源上限 */
function calculateMaxCapacity(workDate, timeSlot) {
  if (!workDate || !timeSlot) return 28;

  // 如果不是今天，返回标准容量
  const todayStr = parseTime(new Date(), '{y}-{m}-{d}');
  if (workDate !== todayStr) {
    if (timeSlot === '上午' || timeSlot === '下午') return 14;
    return 28;
  }

  // 是今天，根据当前时间计算
  const now = new Date();
  const currentHour = now.getHours();
  const currentMinute = now.getMinutes();
  const currentTime = currentHour * 60 + currentMinute;

  let amEnd = 11 * 60 + 30; // 11:30
  let pmEnd = 17 * 60 + 30; // 17:30
  
  // 上午时段计算
  let amSlots = 0;
  if (currentTime < amEnd) {
    let start = Math.max(currentTime, 8 * 60); // 8:00
    let remaining = amEnd - start;
    amSlots = Math.floor(remaining / 15);
  }

  // 下午时段计算
  let pmSlots = 0;
  if (currentTime < pmEnd) {
    let start = Math.max(currentTime, 14 * 60); // 14:00
    // 如果还没到下午上班时间，从14:00开始算
    if (currentTime < 14 * 60) {
      start = 14 * 60;
    }
    let remaining = pmEnd - start;
    pmSlots = Math.floor(remaining / 15);
  }

  if (timeSlot === '上午') return amSlots;
  if (timeSlot === '下午') return pmSlots;
  if (timeSlot === '全天') return amSlots + pmSlots;

  return 28;
}

/** 班次变更自动计算号源上限 */
function handleTimeSlotChange(val) {
  const max = calculateMaxCapacity(form.value.workDate, val);
  form.value.maxCapacity = max;
  form.value.totalCapacity = max;
  form.value.availableSlots = max;
}

/** 日期变更自动计算号源上限 */
function handleWorkDateChange(val) {
  // 检查是否超过当天新增排班时间
  if (!form.value.id && isDoctor.value) { // 仅新增时检查
    if (checkEditTime(val)) {
      proxy.$modal.msgError("已过当天排班新增时间");
      // 清空日期，阻止选择
      form.value.workDate = null;
      return;
    }
  }

  if (form.value.timeSlot) {
    const max = calculateMaxCapacity(val, form.value.timeSlot);
    form.value.maxCapacity = max;
    // 如果当前设置超过上限，重置为上限
    if (form.value.totalCapacity > max) {
      form.value.totalCapacity = max;
      form.value.availableSlots = max;
    }
  }
}

/** 查询排班列表 */
function getList() {
  loading.value = true;
  listSchedule(queryParams.value).then(response => {
    scheduleList.value = response.rows;
    total.value = response.total;
    loading.value = false;
  });
}

/** 日历点击处理 */
function handleDateClick(day) {
  queryParams.value.workDate = day;
  handleQuery();
}

/** 取消排班 */
function handleCancelSchedule(row) {
  if (shouldHideDoctorRowActions(row)) {
    proxy.$modal.msgError("已取消或过期的排班不允许操作");
    return;
  }
  const hasBookedPatient = Number(row.totalCapacity || 0) > Number(row.availableSlots || 0);
  const confirmMsg = isDoctor.value && hasBookedPatient
    ? '已有患者预约该日期排班，是否取消？'
    : '取消排班将同时取消该排班下的所有预约，是否确认取消？';

  proxy.$modal.confirm(confirmMsg).then(function() {
    return updateSchedule({ id: row.id, status: 2 });
  }).then(() => {
    if (isDoctor.value) {
      return import("@/api/hospital/audit").then(module => {
        return module.submitAudit({
          auditType: 'SCHEDULE_CHANGE',
          targetId: row.id,
          requestReason: '医生申请取消排班'
        });
      }).then(() => {
        getList();
        proxy.$modal.msgSuccess("已提交取消申请，请等待管理员审核");
      });
    }
    getList();
    proxy.$modal.msgSuccess("排班已取消");
  }).catch(() => {});
}

/** 取消按钮 */
function cancel() {
  open.value = false;
  reset();
}

/** 表单重置 */
function reset() {
  form.value = {
    id: null,
    deptId: null,
    deptName: null,
    doctorId: isDoctor.value ? currentDoctorId.value : null,
    doctorName: isDoctor.value ? currentDoctorName.value : null,
    workDate: null,
    timeSlot: null,
    totalCapacity: 0,
    availableSlots: 0,
    maxCapacity: 28,
    status: isDoctor.value ? 3 : 0
  };
  doctorOptions.value = [];
  originalTimeSlot.value = "";
  proxy.resetForm("scheduleRef");
}

/** 科室变更加载医生列表 */
function handleDeptChange(deptId) {
  form.value.doctorId = null;
  doctorOptions.value = [];
  if (deptId) {
    listDoctorByDept(deptId).then(response => {
      doctorOptions.value = response.data;
    });
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

/** 搜索按钮操作 */
function handleQuery() {
  getList();
}

/** 回收站按钮操作 */
function handleRecycle() {
  router.push("/hospital/recycle/schedule");
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
  title.value = "添加排班";
  isEditDisabled.value = false; // 新增时默认不禁用，具体看选择的日期
}

/** 检查是否已过修改时间 (当天17:30后) */
function checkEditTime(workDate) {
  if (!isDoctor.value) return false;
  if (!workDate) return false;
  
  const todayStr = parseTime(new Date(), '{y}-{m}-{d}');
  const targetDateStr = parseTime(workDate, '{y}-{m}-{d}');
  if (targetDateStr === todayStr) {
    const now = new Date();
    // 17:30 = 17 * 60 + 30 = 1050 分钟
    const deadline = 17 * 60 + 30;
    const current = now.getHours() * 60 + now.getMinutes();
    return current > deadline;
  }
  return false;
}

/** 医生端是否隐藏操作按钮 */
function shouldHideDoctorRowActions(row) {
  if (!isDoctor.value || !row) return false;
  const status = Number(row.status);
  const workDate = new Date(row.workDate);
  if (Number.isNaN(workDate.getTime())) return false;

  const today = new Date();
  today.setHours(0, 0, 0, 0);
  workDate.setHours(0, 0, 0, 0);

  return status === 2 || workDate.getTime() < today.getTime();
}

/** 医生端是否符合申请删除条件 */
function canDoctorApplyDelete(row) {
  if (!row) return false;
  const workDateStr = parseTime(row.workDate, '{y}-{m}-{d}');
  const todayStr = parseTime(new Date(), '{y}-{m}-{d}');
  return !!workDateStr && workDateStr > todayStr && Number(row.status) === 2;
}

/** 列表行是否允许勾选 */
function isRowSelectable(row) {
  if (!isDoctor.value) return true;
  return canDoctorApplyDelete(row);
}

/** 修改按钮操作 */
function handleUpdate(row) {
  if (shouldHideDoctorRowActions(row)) {
    proxy.$modal.msgError("已取消或过期的排班不允许操作");
    return;
  }
  reset();
  const id = row.id || ids.value;
  // 先把当前行的数据存下来，防止详情接口返回数据不全
  const rowData = { ...row };
  
  // 检查是否禁用修改
  if (checkEditTime(rowData.workDate)) {
    isEditDisabled.value = true;
  } else {
    isEditDisabled.value = false;
  }

  getSchedule(id).then(response => {
    form.value = response.data;
    // 如果详情接口没有返回名称，使用列表行中的名称
    if (!form.value.deptName && rowData.deptName) {
      form.value.deptName = rowData.deptName;
    }
    if (!form.value.doctorName && rowData.doctorName) {
      form.value.doctorName = rowData.doctorName;
    }
    originalTotalCapacity.value = form.value.totalCapacity;
    originalTimeSlot.value = form.value.timeSlot;
    if (isDoctor.value && !form.value.doctorName) {
      form.value.doctorName = currentDoctorName.value;
    }
    // 管理员模式下加载该科室的医生列表
    if (!isDoctor.value && form.value.deptId) {
      listDoctorByDept(form.value.deptId).then(res => {
        doctorOptions.value = res.data;
      });
    }
    // 设置号源上限
    const max = calculateMaxCapacity(form.value.workDate, form.value.timeSlot);
    form.value.maxCapacity = max;
    
    open.value = true;
    title.value = "修改排班";
  });
}

/** 提交按钮 */
function submitForm() {
  proxy.$refs["scheduleRef"].validate(valid => {
    if (valid) {
      if (form.value.id != null) {
        if (form.value.totalCapacity !== originalTotalCapacity.value || form.value.timeSlot !== originalTimeSlot.value) {
          if (form.value.status !== 2) {
            form.value.status = isDoctor.value ? 3 : 1;
          }
        }
        // 修改时，如果调整了总号源，需要同步调整剩余号源
        const diff = form.value.totalCapacity - originalTotalCapacity.value;
        if (diff !== 0) {
          form.value.availableSlots = Math.max(0, form.value.availableSlots + diff);
        }
        updateSchedule(form.value).then(response => {
          if (isDoctor.value) {
            import("@/api/hospital/audit").then(module => {
              const auditData = {
                auditType: 'SCHEDULE_CHANGE',
                targetId: form.value.id,
                requestReason: '医生调整排班'
              };
              module.submitAudit(auditData).then(() => {
                proxy.$modal.msgSuccess("已提交管理员审核");
                open.value = false;
                getList();
              });
            });
          } else {
            proxy.$modal.msgSuccess("修改成功");
            open.value = false;
            getList();
          }
        });
      } else {
        addSchedule(form.value).then(response => {
          if (isDoctor.value) {
            const query = {
              doctorId: currentDoctorId.value,
              workDate: form.value.workDate,
              timeSlot: form.value.timeSlot
            };
            listSchedule(query).then(res2 => {
              if (res2.rows && res2.rows.length > 0) {
                const scheduleId = res2.rows[0].id;
                import("@/api/hospital/audit").then(module => {
                  const auditData = {
                    auditType: 'SCHEDULE_CHANGE',
                    targetId: scheduleId,
                    requestReason: '医生新增排班'
                  };
                  module.submitAudit(auditData).then(() => {
                    proxy.$modal.msgSuccess("已提交管理员审核");
                    open.value = false;
                    getList();
                  });
                });
              } else {
                proxy.$modal.msgSuccess("已提交管理员审核");
                open.value = false;
                getList();
              }
            });
          } else {
            proxy.$modal.msgSuccess("新增成功");
            open.value = false;
            getList();
          }
        });
      }
    }
  });
}

/** 删除按钮操作 */
function handleDelete(row) {
  if (row && shouldHideDoctorRowActions(row)) {
    proxy.$modal.msgError("已取消或过期的排班不允许操作");
    return;
  }
  const scheduleIds = row.id || ids.value;
  // 医生端仅允许申请删除：日期大于今天且状态为已取消(2)
  if (isDoctor.value) {
    const checkRows = row.id ? [row] : scheduleList.value.filter(item => ids.value.includes(item.id));
    const hasInvalidSchedule = checkRows.some(item => !canDoctorApplyDelete(item));
    
    if (hasInvalidSchedule) {
      proxy.$modal.msgError("仅可申请删除日期大于今天且状态为“已取消”的排班");
      return;
    }
  }

  proxy.$modal.confirm('是否确认删除排班编号为"' + scheduleIds + '"的数据项？').then(function() {
    return delSchedule(scheduleIds);
  }).then(() => {
    if (isDoctor.value) {
      // 医生端需要提交审核记录
      import("@/api/hospital/audit").then(module => {
        // 如果是批量删除，需要为每个ID提交一条审核记录？或者简化处理，只提交一条
        // 为了简化，目前假设一次操作生成一条审核记录，但后端可能并没有真正物理删除
        // 实际上后端 deleteScheduleByIds 已经将状态改为 4
        // 我们需要在这里补充提交审核记录，以便管理员能看到申请原因
        const idArray = Array.isArray(scheduleIds) ? scheduleIds : [scheduleIds];
        
        // 使用 Promise.all 并行提交审核
        const promises = idArray.map(id => {
          return module.submitAudit({
            auditType: 'SCHEDULE_CHANGE',
            targetId: id,
            requestReason: '医生申请删除排班'
          });
        });
        
        Promise.all(promises).then(() => {
          getList();
          proxy.$modal.msgSuccess("已提交删除申请，请等待管理员审核");
        });
      });
    } else {
      getList();
      proxy.$modal.msgSuccess("删除成功");
    }
  }).catch(() => {});
}

</script>

<style scoped>
.mini-calendar :deep(.el-calendar-table .el-calendar-day) {
  height: 40px;
  padding: 0;
  display: flex;
  align-items: center;
  justify-content: center;
}

.calendar-cell {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
}

.mini-calendar :deep(.el-calendar__header) {
  padding: 10px;
}

.mini-calendar :deep(.el-calendar__body) {
  padding: 0;
}

.doctor-suggestion {
  display: flex;
  align-items: center;
}

.filter-select {
  width: 130px;
}

.filter-select-dept {
  margin-right: 5px;
}

@media (max-width: 768px) {
  .calendar-col {
    display: none;
  }

  .mb8 :deep(.el-col) {
    width: 100%;
    max-width: 100%;
    flex: 0 0 100%;
    margin-bottom: 8px;
  }

  .mb8 :deep(.el-button) {
    width: 100%;
  }

  .list-col {
    margin-bottom: 12px;
  }

  .filter-select,
  .filter-select-dept {
    width: 100% !important;
    margin-right: 0;
  }

  .doctor-suggestion {
    flex-wrap: wrap;
    row-gap: 4px;
  }

  .mini-calendar :deep(.el-calendar-table .el-calendar-day) {
    height: 34px;
  }

  .calendar-cell {
    font-size: 12px;
  }

  .app-container :deep(.el-table) {
    font-size: 13px;
  }
}
</style>
