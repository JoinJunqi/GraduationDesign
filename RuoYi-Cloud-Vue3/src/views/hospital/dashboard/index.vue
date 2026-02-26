<template>
  <div class="dashboard-container">
    <div class="filter-container mb20">
      <el-button-group>
        <el-button :type="!selectedDate ? 'primary' : ''" @click="handleOverview">总览</el-button>
        <el-date-picker
          v-model="selectedDate"
          type="date"
          placeholder="选择日期"
          value-format="YYYY-MM-DD"
          @change="handleDateChange"
          style="width: 160px"
        />
      </el-button-group>
      <span v-if="selectedDate" class="selected-text ml10">
        正在查看: {{ selectedDate }} 的数据
      </span>
    </div>

    <el-row :gutter="20" class="mb20">
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <template #header>
            <div class="card-header">
              <span>总预约量</span>
              <el-tag type="success">全部</el-tag>
            </div>
          </template>
          <div class="stat-value">{{ stats.totalAppointments || 0 }}</div>
          <div class="stat-footer">历史累计预约人次</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <template #header>
            <div class="card-header">
              <span>今日预约</span>
              <el-tag type="primary">今日</el-tag>
            </div>
          </template>
          <div class="stat-value">{{ stats.todayAppointments || 0 }}</div>
          <div class="stat-footer">今日新增预约人数</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <template #header>
            <div class="card-header">
              <span>注册患者</span>
              <el-tag type="warning">总计</el-tag>
            </div>
          </template>
          <div class="stat-value">{{ stats.totalPatients || 0 }}</div>
          <div class="stat-footer">系统内患者总数</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <template #header>
            <div class="card-header">
              <span>在职医生</span>
              <el-tag type="danger">总计</el-tag>
            </div>
          </template>
          <div class="stat-value">{{ stats.totalDoctors || 0 }}</div>
          <div class="stat-footer">系统内在职医生总数</div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20" class="mb20">
      <el-col :span="16">
        <el-card shadow="hover">
          <template #header>
            <div class="card-header">
              <span>近7天预约趋势</span>
            </div>
          </template>
          <div ref="trendChartRef" class="chart-box"></div>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card shadow="hover">
          <template #header>
            <div class="card-header">
              <span>预约状态分布</span>
            </div>
          </template>
          <div ref="statusChartRef" class="chart-box"></div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20">
      <el-col :span="24">
        <el-card shadow="hover">
          <template #header>
            <div class="card-header">
              <span>各科室预约分布</span>
            </div>
          </template>
          <div ref="deptChartRef" class="chart-box" style="height: 400px;"></div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup name="Dashboard">
import { ref, onMounted, onUnmounted, nextTick } from 'vue';
import * as echarts from 'echarts';
import { getDashboardStats } from "@/api/hospital/appointment";

const stats = ref({});
const trendChartRef = ref(null);
const statusChartRef = ref(null);
const deptChartRef = ref(null);
const selectedDate = ref(null);

let trendChart = null;
let statusChart = null;
let deptChart = null;

const chartsReady = ref(false);

// 处理总览
const handleOverview = () => {
  selectedDate.value = null;
  loadData();
};

// 处理日期变更
const handleDateChange = (val) => {
  loadData();
};

// 初始化图表
const initCharts = () => {
  if (!trendChartRef.value || trendChartRef.value.clientWidth === 0) {
    setTimeout(initCharts, 100);
    return;
  }

  try {
    trendChart = echarts.init(trendChartRef.value);
    statusChart = echarts.init(statusChartRef.value);
    deptChart = echarts.init(deptChartRef.value);
    chartsReady.value = true;

    // 如果数据已经加载，则更新图表
    if (stats.value && Object.keys(stats.value).length > 0) {
      updateCharts(stats.value);
    }

    window.addEventListener('resize', handleResize);
  } catch (e) {
    console.error("ECharts 初始化失败:", e);
  }
};

const handleResize = () => {
  if (chartsReady.value) {
    trendChart?.resize();
    statusChart?.resize();
    deptChart?.resize();
  }
};

const loadData = async () => {
  try {
    const res = await getDashboardStats({ date: selectedDate.value });
    if (res.code === 200) {
      stats.value = res.data;
      if (chartsReady.value) {
        updateCharts(res.data);
      }
    }
  } catch (error) {
    console.error("加载看板数据失败:", error);
  }
};

const updateCharts = (data) => {
  if (!chartsReady.value || !trendChart || !statusChart || !deptChart) return;
  
  // 1. 趋势图 (折线图)
  const trendData = data.trend || [];
  trendChart.setOption({
    tooltip: {
      trigger: 'axis',
      backgroundColor: 'rgba(255, 255, 255, 0.9)',
      borderWidth: 1,
      borderColor: '#eee',
      textStyle: { color: '#333' }
    },
    grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
    xAxis: {
      type: 'category',
      boundaryGap: false,
      data: trendData.map(item => item.date),
      axisLine: { lineStyle: { color: '#999' } }
    },
    yAxis: {
      type: 'value',
      axisLine: { show: false },
      splitLine: { lineStyle: { type: 'dashed', color: '#eee' } }
    },
    series: [{
      name: '预约人数',
      type: 'line',
      smooth: true,
      data: trendData.map(item => item.count),
      itemStyle: { color: '#409EFF' },
      areaStyle: {
        color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
          { offset: 0, color: 'rgba(64,158,255,0.3)' },
          { offset: 1, color: 'rgba(64,158,255,0)' }
        ])
      },
      emphasis: { scale: true }
    }]
  });

  // 2. 状态分布 (环形饼图)
  const statusData = data.statusDistribution || [];
  statusChart.setOption({
    tooltip: { trigger: 'item', formatter: '{b}: {c} ({d}%)' },
    legend: { bottom: '0', left: 'center' },
    series: [{
      name: '预约状态',
      type: 'pie',
      radius: ['40%', '70%'],
      avoidLabelOverlap: false,
      itemStyle: { borderRadius: 10, borderColor: '#fff', borderWidth: 2 },
      label: { show: false, position: 'center' },
      emphasis: { label: { show: true, fontSize: '16', fontWeight: 'bold' } },
      data: statusData
    }]
  });

  // 3. 科室分布 (横向柱状图)
  const deptData = (data.deptDistribution || []).sort((a, b) => a.value - b.value);
  deptChart.setOption({
    tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
    grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
    xAxis: { type: 'value', axisLine: { show: false }, splitLine: { lineStyle: { color: '#eee' } } },
    yAxis: {
      type: 'category',
      data: deptData.map(item => item.name),
      axisLine: { lineStyle: { color: '#999' } }
    },
    series: [{
      name: '预约人数',
      type: 'bar',
      data: deptData.map(item => item.value),
      itemStyle: {
        color: new echarts.graphic.LinearGradient(1, 0, 0, 0, [
          { offset: 0, color: '#67C23A' },
          { offset: 1, color: '#b3e19d' }
        ]),
        borderRadius: [0, 5, 5, 0]
      },
      barWidth: '50%'
    }]
  });
};

onMounted(() => {
  nextTick(() => {
    initCharts();
    loadData();
  });
});

onUnmounted(() => {
  window.removeEventListener('resize', handleResize);
  trendChart?.dispose();
  statusChart?.dispose();
  deptChart?.dispose();
});
</script>

<style scoped>
.dashboard-container {
  padding: 20px;
  background-color: #f5f7fa;
  min-height: calc(100vh - 84px);
}

.filter-container {
  display: flex;
  align-items: center;
  background: #fff;
  padding: 15px;
  border-radius: 8px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.05);
}

.selected-text {
  color: #409eff;
  font-weight: bold;
}

.ml10 {
  margin-left: 10px;
}

.mb20 {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: bold;
}

.stat-card {
  text-align: center;
}

.stat-value {
  font-size: 30px;
  font-weight: bold;
  color: #303133;
  margin: 10px 0;
}

.stat-footer {
  font-size: 13px;
  color: #909399;
}

.chart-box {
  height: 300px;
  width: 100%;
}
</style>