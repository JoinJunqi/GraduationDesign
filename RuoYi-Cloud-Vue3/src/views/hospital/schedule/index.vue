<template>
  <div class="app-container">
    <el-row :gutter="20">
      <!-- 左侧日历 -->
      <el-col :span="6" v-if="!isDoctor">
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
      <el-col :span="isDoctor ? 24 : 18">
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

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button
          type="primary"
          plain
          icon="Plus"
          @click="handleAdd"
          v-hasPermi="['hospital:schedule:add']"
        >新增</el-button>
      </el-col>
      <el-col :span="1.5">
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
        >删除</el-button>
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
      <el-table-column type="selection" width="55" align="center" />
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
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['hospital:schedule:edit']">修改</el-button>
          <el-button link type="primary" icon="CircleClose" @click="handleCancelSchedule(scope.row)" v-if="scope.row.status !== 2" v-hasPermi="['hospital:schedule:edit']">取消</el-button>
          <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)" v-hasPermi="['hospital:schedule:remove']">删除</el-button>
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
    <el-dialog :title="title" v-model="open" width="500px" append-to-body>
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
          <el-date-picker
            v-model="form.workDate"
            type="date"
            placeholder="选择出诊日期"
            value-format="YYYY-MM-DD"
          />
        </el-form-item>
        <el-form-item label="班次" prop="timeSlot">
          <el-select v-model="form.timeSlot" placeholder="请选择班次" @change="handleTimeSlotChange">
            <el-option label="上午" value="上午" />
            <el-option label="下午" value="下午" />
            <el-option label="全天" value="全天" />
          </el-select>
        </el-form-item>
        <el-form-item label="总号源" prop="totalCapacity">
          <el-input-number v-model="form.totalCapacity" :min="1" :max="form.maxCapacity || 28" />
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
          <el-button type="primary" @click="submitForm">确 定</el-button>
          <el-button @click="cancel">取 消</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="Schedule">
import { ref, reactive, toRefs, computed, getCurrentInstance, onMounted } from 'vue';
import { listSchedule, getSchedule, delSchedule, addSchedule, updateSchedule } from "@/api/hospital/schedule";
import { listDepartment } from "@/api/hospital/department";
import { listDoctorByDept, listDoctor } from "@/api/hospital/doctor";
import useUserStore from "@/store/modules/user";
import { useRouter } from 'vue-router';

const userStore = useUserStore();
const { proxy } = getCurrentInstance();
const { parseTime } = proxy;
const router = useRouter();

const isDoctor = computed(() => userStore.roles.includes('doctor'));
const currentDoctorName = computed(() => userStore.nickName);
const currentDoctorId = computed(() => userStore.id);

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

/** 班次变更自动计算号源上限 */
function handleTimeSlotChange(val) {
  let capacity = 0;
  if (val === '上午' || val === '下午') {
    capacity = 14; // 3.5小时 * 60 / 15 = 14
  } else if (val === '全天') {
    capacity = 28; // 7小时 * 60 / 15 = 28
  }
  form.value.maxCapacity = capacity;
  form.value.totalCapacity = capacity;
  form.value.availableSlots = capacity;
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
  proxy.$modal.confirm('取消排班将同时取消该排班下的所有预约，是否确认取消？').then(function() {
    return updateSchedule({ id: row.id, status: 2 });
  }).then(() => {
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
    status: 0
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
}

/** 修改按钮操作 */
function handleUpdate(row) {
  reset();
  const id = row.id || ids.value;
  // 先把当前行的数据存下来，防止详情接口返回数据不全
  const rowData = { ...row };
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
    if (form.value.timeSlot === '上午' || form.value.timeSlot === '下午') {
      form.value.maxCapacity = 14;
    } else if (form.value.timeSlot === '全天') {
      form.value.maxCapacity = 28;
    }
    open.value = true;
    title.value = "修改排班";
  });
}

/** 提交按钮 */
function submitForm() {
  proxy.$refs["scheduleRef"].validate(valid => {
    if (valid) {
      if (form.value.id != null) {
        // 修改时，如果调整了总号源或班次，状态自动变更为“有调整”(1)
        if (form.value.totalCapacity !== originalTotalCapacity.value || form.value.timeSlot !== originalTimeSlot.value) {
          if (form.value.status !== 2) { // 除非原状态是已取消，否则变更为有调整
            form.value.status = 1;
          }
        }
        // 修改时，如果调整了总号源，需要同步调整剩余号源
        const diff = form.value.totalCapacity - originalTotalCapacity.value;
        if (diff !== 0) {
          form.value.availableSlots = Math.max(0, form.value.availableSlots + diff);
        }
        updateSchedule(form.value).then(response => {
          proxy.$modal.msgSuccess("修改成功");
          open.value = false;
          getList();
        });
      } else {
        // 新增时检查重复日期
        const checkQuery = {
          doctorId: form.value.doctorId,
          workDate: form.value.workDate
        };
        listSchedule(checkQuery).then(res => {
          if (res.rows && res.rows.length > 0) {
            proxy.$modal.msgError("该日期已存在排班，请勿重复添加");
            return;
          }
          addSchedule(form.value).then(response => {
            proxy.$modal.msgSuccess("新增成功");
            open.value = false;
            getList();
          });
        });
      }
    }
  });
}

/** 删除按钮操作 */
function handleDelete(row) {
  const scheduleIds = row.id || ids.value;
  proxy.$modal.confirm('是否确认删除排班编号为"' + scheduleIds + '"的数据项？').then(function() {
    return delSchedule(scheduleIds);
  }).then(() => {
    getList();
    proxy.$modal.msgSuccess("删除成功");
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
</style>
