<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="医生姓名" prop="doctorName">
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
      <el-form-item label="医生筛选">
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
      <el-form-item label="出诊日期" prop="workDate">
        <el-date-picker
          v-model="queryParams.workDate"
          type="date"
          value-format="YYYY-MM-DD"
          placeholder="选择日期"
          @change="handleQuery"
        />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
        <el-button type="warning" icon="Back" @click="handleBack">返回</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button
          type="success"
          plain
          icon="RefreshLeft"
          :disabled="multiple"
          @click="handleRecover"
          v-if="!isDoctor"
          v-hasPermi="['hospital:schedule:edit']"
        >批量恢复</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-alert
      v-if="isDoctor"
      title="仅管理员可恢复，请联系管理员"
      type="warning"
      :closable="false"
      show-icon
      class="mb8"
    />

    <el-table v-loading="loading" :data="scheduleList" @selection-change="handleSelectionChange" @sort-change="handleSortChange">
      <el-table-column v-if="isDoctor" type="index" label="序号" width="70" align="center" :index="getTableIndex" />
      <el-table-column v-if="!isDoctor" type="selection" width="55" align="center" />
      <el-table-column label="医生" align="center" prop="doctorName" />
      <el-table-column label="职称" align="center" prop="title" />
      <el-table-column label="出诊日期" align="center" prop="workDate" width="120" sortable="custom">
        <template #default="scope">
          <span>{{ parseTime(scope.row.workDate, '{y}-{m}-{d}') }}</span>
        </template>
      </el-table-column>
      <el-table-column label="班次" align="center" prop="timeSlot" sortable="custom" />
      <el-table-column label="删除时间" align="center" prop="deletedAt" width="180" sortable="custom">
        <template #default="scope">
          <span>{{ parseTime(scope.row.deletedAt) }}</span>
        </template>
      </el-table-column>
      <el-table-column v-if="!isDoctor" label="操作" align="center" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button link type="success" icon="RefreshLeft" @click="handleRecover(scope.row)" v-hasPermi="['hospital:schedule:edit']">恢复</el-button>
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
  </div>
</template>

<script setup name="ScheduleRecycle">
import { listSchedule, recoverSchedule } from "@/api/hospital/schedule";
import { listDepartment } from "@/api/hospital/department";
import { listDoctorByDept, listDoctor } from "@/api/hospital/doctor";
import { getCurrentInstance, ref, reactive, toRefs, onMounted, computed } from "vue";
import { useRouter } from "vue-router";
import useUserStore from "@/store/modules/user";

const { proxy } = getCurrentInstance();
const router = useRouter();
const userStore = useUserStore();
// 医生在回收站仅可查看，恢复权限由管理员执行
const isDoctor = computed(() => userStore.roles.includes('doctor'));

// 排班回收站页面状态：列表、筛选、分页与批量恢复
const scheduleList = ref([]);
const loading = ref(true);
const showSearch = ref(true);
const ids = ref([]);
const multiple = ref(true);
const total = ref(0);
const departmentList = ref([]);
const queryDoctorOptions = ref([]);

const data = reactive({
  queryParams: {
    // 固定查询软删除数据
    pageNum: 1,
    pageSize: 10,
    doctorName: null,
    deptId: null,
    doctorId: null,
    workDate: null,
    orderByColumn: "deletedAt",
    isAsc: "descending",
    params: {
      includeDeleted: "true",
      onlyDeleted: "true"
    }
  }
});

const { queryParams } = toRefs(data);

/** 查询科室列表 */
function getDepartmentList() {
  // 科室筛选用于缩小回收站检索范围
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
  // 科室变化后清空医生选择，避免脏条件
  queryParams.value.doctorId = null;
  queryDoctorOptions.value = [];
  if (deptId) {
    listDoctorByDept(deptId).then(response => {
      queryDoctorOptions.value = response.data;
    });
  }
  handleQuery();
}

/** 查询排班列表 */
function getList() {
  loading.value = true;
  // 复用 listSchedule 接口，通过 params 进入“回收站模式”
  listSchedule(queryParams.value).then(response => {
    scheduleList.value = response.rows;
    total.value = response.total;
    loading.value = false;
  });
}

/** 排序触发事件 */
function handleSortChange(column) {
  queryParams.value.orderByColumn = column.prop;
  queryParams.value.isAsc = column.order;
  getList();
}

/** 搜索按钮操作 */
function handleQuery() {
  queryParams.value.pageNum = 1;
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
  // 批量恢复按钮禁用态
  ids.value = selection.map(item => item.id);
  multiple.value = !selection.length;
}

/** 计算跨页连续序号 */
function getTableIndex(index) {
  return (queryParams.value.pageNum - 1) * queryParams.value.pageSize + index + 1;
}

/** 恢复按钮操作 */
function handleRecover(row) {
  const scheduleIds = row.id || ids.value;
  // 恢复后排班重新回到主排班列表
  proxy.$modal.confirm('是否确认恢复排班编号为"' + scheduleIds + '"的数据项？').then(function () {
    return recoverSchedule(scheduleIds);
  }).then((res) => {
    if (res && res.data) {
      getList();
      proxy.$modal.msgSuccess("恢复成功");
      return;
    }
    proxy.$modal.msgError("恢复失败，请刷新后重试");
  }).catch(() => {});
}

/** 返回操作 */
function handleBack() {
  router.push("/hospital/schedule");
}

onMounted(() => {
  getDepartmentList();
  getList();
});
</script>
