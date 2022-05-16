# © International Renewable Energy Agency 2018-2022

#The FlexTool is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License
#as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

#The FlexTool is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
#without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more details.

#You should have received a copy of the GNU Lesser General Public License along with the FlexTool.  
#If not, see <https://www.gnu.org/licenses/>.

#Author: Juha Kiviluoma (2017-2022), VTT Technical Research Centre of Finland

#########################
# Fundamental sets of the model
set entity 'e - contains both nodes and processes';
set process 'p - Particular activity that transfers, converts or stores commodities' within entity;
set processUnit 'Unit processes' within process;
set processTransfer 'Transfer processes' within process;
set node 'n - Any location where a balance needs to be maintained' within entity;
set group 'g - Any group of entities that have a set of common constraints';
set commodity 'c - Stuff that is being processed';
set reserve__upDown__group__method dimen 4;
set reserve__upDown__group := setof {(r, ud, g, m) in reserve__upDown__group__method : m <> 'no_reserve'} (r, ud, g);
set reserve 'r - Categories for the reservation of capacity_existing' := setof {(r, ud, ng, r_m) in reserve__upDown__group__method} (r);
set period_time '(d, t) - Time steps in the time periods of the timelines in use' dimen 2;
set solve_period_timeblockset '(solve, d, tb) - All solve, period, timeblockset combinations in the model instance' dimen 3;
set solve_period '(solve, d) - Time periods in the solves to extract periods that can be found in the full data' := setof {(s, d, tb) in solve_period_timeblockset} (s, d);
set periodAll 'd - Time periods in data (including those currently in use)' := setof {(s, d) in solve_period} (d);
set solve_current 'current solve name' dimen 1;
set period 'd - Time periods in the current solve' := setof {(d, t) in period_time} (d);
set time 't - Time steps in the current timelines'; 
set method 'm - Type of process that transfers, converts or stores commodities';
set upDown 'upward and downward directions for some variables';
set ct_method;
set startup_method;
set fork_method;
set fork_method_yes within fork_method;
set fork_method_no within fork_method;
set reserve_method;
set ramp_method;
set ramp_limit_method within ramp_method;
set ramp_cost_method within ramp_method;
set profile;
set profile_method;
set debug 'flags to output debugging and test results';
set test_dt 'a shorter set of time steps for printing out test results' dimen 2;

set constraint 'user defined greater than, less than or equality constraints between inputs and outputs';
set sense 'sense of user defined constraints';
set sense_greater_than within sense;
set sense_less_than within sense;
set sense_equal within sense;

#Method collections use in the model (abstracted methods)
set method_1var_off within method;
set method_1way_off within method;
set method_1way_LP within method;
set method_1way_MIP within method;
set method_2way_off within method;
set method_1way_1var_on within method;
set method_1way_nvar_on within method;
set method_1way within method;
set method_1way_1var within method;
set method_2way_1var within method;
set method_2way within method;
set method_2way_2var within method;
set method_2way_nvar within method;
set method_1way_on within method;
set method_2way_on within method;
set method_1var within method;
set method_nvar within method;
set method_off within method;
set method_on within method;
set method_LP within method;
set method_MIP within method;
set method_direct within method;
set method_indirect within method;
set method_1var_per_way within method;

set invest_method 'methods available for investments';
set invest_method_not_allowed 'method for denying investments' within invest_method;
set entity__invest_method 'the investment method applied to an entity' dimen 2 within {entity, invest_method};
set entityInvest := setof {(e, m) in entity__invest_method : m not in invest_method_not_allowed} (e);
set nodeBalance 'nodes that maintain a node balance' within node;
set nodeState 'nodes that have a state' within node;
set inflow_method 'method for scaling the inflow';
set node__inflow_method 'method for scaling the inflow applied to a node' within {node, inflow_method};
set group_node 'member nodes of a particular group' dimen 2 within {group, node};
set group_process 'member processes of a particular group' dimen 2 within {group, process};
set group_process_node 'process__nodes of a particular group' dimen 3 within {group, process, node};
set group_entity := group_process union group_node;
set groupInertia 'node groups with an inertia constraint' within group;
set groupNonSync 'node groups with a non-synchronous constraint' within group;
set groupCapacityMargin 'node groups with a capacity margin' within group;
set groupOutput 'groups that will output aggregated results' within group;
set process_unit 'processes that are unit' within process;
set process_connection 'processes that are connections' within process;
set process_ct_method dimen 2 within {process, ct_method};
set process_startup_method dimen 2 within {process, startup_method};
set process_node_ramp_method dimen 3 within {process, node, ramp_method};
set methods dimen 4; 
set process__profile__profile_method dimen 3 within {process, profile, profile_method};
set process__node__profile__profile_method dimen 4 within {process, node, profile, profile_method};
set process_source dimen 2 within {process, entity};
set process_sink dimen 2 within {process, entity};
set process_fork_method{p in process, m in fork_method} dimen 2 within {process, fork_method} := 
    if (sum{(p, source) in process_source} 1 > 1 || sum{(p, sink) in process_sink} 1 > 1)
	then process cross fork_method_yes
	else process cross fork_method_no;
set process_ct_startup_fork_method := 
    { p in process, m1 in ct_method, m2 in startup_method, m3 in fork_method, m in method
	    : (m1, m2, m3, m) in methods
	    && (p, m1) in process_ct_method
	    && (p, m2) in process_startup_method 
		&& (p, m3) in process_fork_method[p,m3]
	};
set process_method := setof {(p, m1, m2, m3, m) in process_ct_startup_fork_method} (p, m);
set process_source_toProcess := 
    { p in process, source in node, p2 in process 
	    :  p = p2 
	    && (p, source) in process_source 
	    && (p2, source) in process_source 
	    && sum{(p, m) in process_method : m in method_indirect} 1
	};
set process_process_toSink := 
    { p in process, p2 in process, sink in node 
	    :  p = p2 
	    && (p, sink) in process_sink 
	    && (p2, sink) in process_sink 
	    && sum{(p, m) in process_method : m in method_indirect} 1
	};
set process_sink_toProcess := 
    { sink in node, p in process, p2 in process 
	    :  p = p2 
	    && (p, sink) in process_sink 
	    && (p2, sink) in process_sink 
	    && sum{(p, m) in process_method : m in method_2way_nvar} 1
	};
set process_process_toSource := 
    { p in process, p2 in process, source in node 
	    :  p = p2 
	    && (p, source) in process_source
	    && (p2, source) in process_source
	    && sum{(p, m) in process_method : m in method_2way_nvar} 1
	};
set process_source_toSink := 
    { p in process, source in node, sink in node
	    :  (p, source) in process_source
	    && (p, sink) in process_sink
        && sum{(p, m) in process_method : m in method_direct} 1
	};
set process_source_toProcess_direct :=
    { p in process, source in node, p2 in process
	    :  p = p2
		&& (p, source) in process_source
        && sum{(p, m) in process_method : m in method_direct} 1
	};
set process_process_toSink_direct :=
    { p in process, p2 in process, sink in node
	    :  p = p2
		&& (p, sink) in process_sink
        && sum{(p, m) in process_method : m in method_direct} 1
	};
set process_sink_toSource := 
	{ p in process, sink in node, source in node
	    :  (p, source) in process_source
	    && (p, sink) in process_sink
	    && sum{(p, m) in process_method : m in method_2way_2var} 1
	};
set process_sink_toProcess_direct := 
	{ p in process, sink in node, p2 in process
	    :  p = p2
		&& (p, sink) in process_sink
	    && sum{(p, m) in process_method : m in method_2way_2var} 1
	};
set process_process_toSource_direct := 
	{ p in process, p2 in process, source in node
	    :  p = p2
		&& (p, source) in process_source
	    && sum{(p, m) in process_method : m in method_2way_2var} 1
	};
set process__profileProcess__toSink__profile__profile_method :=
    { p in process, p2 in process, sink in node, f in profile, m in profile_method
	    :  p = p2
		&& (p, sink) in process_sink
		&& (p2, sink, f, m) in process__node__profile__profile_method
	};
set process__profileProcess__toSink := setof {(p, p2, sink, f, m) in process__profileProcess__toSink__profile__profile_method} (p, p2, sink);
set process__source__toProfileProcess__profile__profile_method :=
    { p in process, source in node, p2 in process, f in profile, m in profile_method
	    :  p = p2
		&& (p, source) in process_source
		&& (p2, source, f, m) in process__node__profile__profile_method
	};
set process__source__toProfileProcess := setof {(p, source, p2, f, m) in process__source__toProfileProcess__profile__profile_method} (p, source, p2);

set process_source_sink := 
    process_source_toSink union    # Direct 1-variable
	process_sink_toSource union    # Direct 1-variable, but the other way
	process_source_toProcess union # First step for indirect (from source to process)
	process_process_toSink union   # Second step for indirect (from process to sink)
	process_sink_toProcess union   # Add the 'wrong' direction in 2-way processes with multiple inputs/outputs
	process_process_toSource union # Add the 'wrong' direction in 2-way processes with multiple inputs/outputs
	process__profileProcess__toSink union   # Add profile based inputs to process
	process__source__toProfileProcess;	   # Add profile based inputs to process	

set process_source_sink_alwaysProcess :=
    process_source_toProcess_direct union  # Direct 1-variable, but showing the process in between
	process_process_toSink_direct union
	process_sink_toProcess_direct union
	process_process_toSource_direct union
	process_source_toProcess union # First step for indirect (from source to process)
	process_process_toSink union   # Second step for indirect (from process to sink)
	process_sink_toProcess union   # Add the 'wrong' direction in 2-way processes with multiple inputs/outputs
	process_process_toSource union # Add the 'wrong' direction in 2-way processes with multiple inputs/outputs
	process__profileProcess__toSink union   # Add profile based inputs to process
	process__source__toProfileProcess;	   # Add profile based inputs to process	

set process_source_sink_noEff :=
	process_source_toProcess union # First step for indirect (from source to process)
	process_process_toSink union   # Second step for indirect (from process to sink)
	process_sink_toProcess union   # Add the 'wrong' direction in 2-way processes with multiple inputs/outputs
	process_process_toSource union # Add the 'wrong' direction in 2-way processes with multiple inputs/outputs
	process__profileProcess__toSink union   # Add profile based inputs to process
	process__source__toProfileProcess;	   # Add profile based inputs to process	

set process_source_sink_eff :=
    process_source_toSink union    # Direct 1-variable
	process_sink_toSource;         # Direct 1-variable, but the other way

set process__source__sink__profile__profile_method_connection :=
    { (p, sink, source) in process_source_sink, f in profile, m in profile_method
	    : (p, f, m) in process__profile__profile_method
	};
set process__source__sink__profile__profile_method :=
    process__profileProcess__toSink__profile__profile_method union
	process__source__toProfileProcess__profile__profile_method union
	process__source__sink__profile__profile_method_connection
;

set process_online 'processes with an online status' := setof {(p, m) in process_method : m in method_LP} p;

set commodityParam;
set commodityPeriodParam within commodityParam;
set nodeParam;
set nodePeriodParam;
set nodeTimeParam within nodeParam;
set processParam;
set processPeriodParam;
set processTimeParam within processParam;
set sourceSinkParam;
set sourceSinkTimeParam within sourceSinkParam;
set reserveParam;
set reserveTimeParam within reserveParam;
set groupParam;
set groupPeriodParam;
set groupTimeParam within groupParam;

set process_reserve_upDown_node dimen 4;
set process_node_constraint dimen 3 within {process, node, constraint};
set constraint__sense dimen 2 within {constraint, sense};
set commodity_node dimen 2 within {commodity, node}; 

set dt dimen 2 within period_time;
set dttt dimen 4;
set period_invest dimen 1 within period;
set period_realized dimen 1 within period;
set peedt := {(p, source, sink) in process_source_sink, (d, t) in period_time};

set startTime dimen 1 within time;
set startNext dimen 1 within time;
param startNext_index := sum{t in time, t_startNext in startNext : t <= t_startNext} 1;
set modelParam;
param p_model {modelParam};

set commodity__param__period dimen 3 within {commodity, commodityPeriodParam, periodAll};
param p_commodity {c in commodity, commodityParam};
param pd_commodity {c in commodity, commodityPeriodParam, d in periodAll} default 0;
param pdCommodity {c in commodity, param in commodityPeriodParam, d in period} := 
        + if (c, param, d) in commodity__param__period
		  then pd_commodity[c, param, d]
		  else p_commodity[c, param];

param p_group__process {g in group, p in process, groupParam};

set group__param dimen 2 within {group, groupParam};
set group__param__period dimen 3 within {group, groupPeriodParam, periodAll};
param p_group {g in group, groupParam} default 0;
param pd_group {g in group, groupPeriodParam, d in periodAll} default 0;
param pdGroup {g in group, param in groupPeriodParam, d in period} :=
        + if (g, param, d) in group__param__period
		  then pd_group[g, param, d]
		  else if (g, param) in group__param 
		  then p_group[g, param]
		  else 0;
		  
set node__param__period dimen 3 within {node, nodePeriodParam, periodAll};
set node__param__time dimen 3 within {node, nodeTimeParam, time};
param p_node {node, nodeParam} default 0;
param pd_node {node, nodePeriodParam, periodAll} default 0;
param pt_node {node, nodeTimeParam, time} default 0;
param pdNode {n in node, param in nodePeriodParam, d in period} :=
        + if (n, param, d) in node__param__period
		  then pd_node[n, param, d]
		  else p_node[n, param];
param ptNode {n in node, param in nodeTimeParam, t in time} :=
        + if (n, param, t) in node__param__time
		  then pt_node[n, param, t]
		  else p_node[n, param];
set nodeSelfDischarge :=  {n in nodeState : sum{(d, t) in dt : ptNode[n, 'self_discharge_loss', t]} 1};
		  

set process__param dimen 2 within {process, processParam};
set process__param__period dimen 3 within {process, processPeriodParam, periodAll};
set process__param__time dimen 3 within {process, processTimeParam, time};
set process__param_t := setof {(p, param, t) in process__param__time} (p, param);

set connection__param := {(p, param) in process__param : p in process_connection};
set connection__param__time := { (p, param, t) in process__param__time : (p in process_connection)};
set connection__param_t := setof {(connection, param, t) in connection__param__time} (connection, param);
set process__source__param dimen 3 within {process_source, sourceSinkParam};
set process__source__param__time dimen 4 within {process_source, sourceSinkTimeParam, time};
set process__source__param_t := setof {(p, source, param, t) in process__source__param__time} (p, source, param);
set process__sink__param dimen 3 within {process_sink, sourceSinkParam};
set process__sink__param__time dimen 4 within {process_sink, sourceSinkTimeParam, time};
set process__sink__param_t := setof {(p, sink, param, t) in process__sink__param__time} (p, sink, param);

set process__source__timeParam := 
    { (p, source) in process_source, param in sourceSinkTimeParam
	    :  (p, source, param) in process__source__param
	    || (p, source, param) in process__source__param_t
	};

set process__sink__timeParam :=
    { (p, sink) in process_sink, param in sourceSinkTimeParam
	    :  (p, sink, param) in process__sink__param
	    || (p, sink, param) in process__sink__param_t
	};

set process__timeParam :=
    { p in process, param in sourceSinkTimeParam
	   :  ((p, param) in process__param && p in process_connection)
	   || ((p, param) in process__param_t && p in process_connection)
	}; 

set process__source__sink__param :=
    { (p, source, sink) in process_source_sink, param in sourceSinkParam
	    :  (p, source, param) in process__source__param
	    || (p, sink, param) in process__sink__param
	    || ((p, param) in process__param && p in process_connection)
	};
set process__source__sink__param_t :=
    { (p, source, sink) in process_source_sink, param in sourceSinkTimeParam
	    :  (p, source, param) in process__source__param
	    || (p, source, param) in process__source__param_t
	    || (p, sink, param) in process__sink__param
	    || (p, sink, param) in process__sink__param_t
	    || ((p, param) in process__param && p in process_connection)
	    || ((p, param) in process__param_t && p in process_connection)
	};

set process__source__sink__ramp_method :=
    { (p, source, sink) in process_source_sink, m in ramp_method
	    :  (p, source, m) in process_node_ramp_method
		|| (p, sink, m) in process_node_ramp_method
	};

param p_process {process, processParam} default 0;
param pd_process {process, processPeriodParam, periodAll} default 0;
param pt_process {process, processTimeParam, time} default 0;
param pdProcess {p in process, param in processPeriodParam, d in period} :=
        + if (p, param, d) in process__param__period
		  then pd_process[p, param, d]
		  else if (p, param) in process__param
		  then p_process[p, param]
		  else 0;
param ptProcess {p in process, param in processTimeParam, t in time} :=
        + if (p, param, t) in process__param__time
		  then pt_process[p, param, t]
		  else if (p, param) in process__param
		  then p_process[p, param]
		  else 0;

param p_entity_unitsize {e in entity} := 
        + if e in process 
		  then ( if p_process[e, 'virtual_unitsize']
                 then p_process[e, 'virtual_unitsize'] 
		         else if e in process && p_process[e, 'existing']
			          then p_process[e, 'existing']
					  else 1
			   )			 
          else if e in node 
		  then ( if p_node[e, 'virtual_unitsize'] 
                 then p_node[e, 'virtual_unitsize'] 
		         else if e in node && p_node[e, 'existing']
		              then p_node[e, 'existing']
					  else 1
			   );

param p_process_source {(p, source) in process_source, sourceSinkParam} default 0;
param pt_process_source {(p, source) in process_source, sourceSinkTimeParam, time} default 0;
param p_process_sink {(p, sink) in process_sink, sourceSinkParam} default 0;
param pt_process_sink {(p, sink) in process_sink, sourceSinkTimeParam, time} default 0;

param pProcess_source_sink {(p, source, sink, param) in process__source__sink__param} :=
		+ if (p, source, param) in process__source__param
		  then p_process_source[p, source, param]
		  else if (p, sink, param) in process__sink__param
		  then p_process_sink[p, sink, param]
		  else 0;

param ptProcess_source {(p, source) in process_source, param in sourceSinkTimeParam, t in time : sum{d in period : (d, t) in dt} 1} :=
        + if (p, source, param, t) in process__source__param__time
		  then pt_process_source[p, source, param, t]
		  else if (p, source, param) in process__source__param
		  then p_process_source[p, source, param]
		  else 0;
        
param ptProcess_sink {(p, sink) in process_sink, param in sourceSinkTimeParam, t in time : sum{d in period : (d, t) in dt} 1} :=
        + if (p, sink, param, t) in process__sink__param__time
		  then pt_process_sink[p, sink, param, t]
		  else if (p, sink, param) in process__sink__param
		  then p_process_sink[p, sink, param]
		  else 0;

param ptProcess_source_sink {(p, source, sink, param) in process__source__sink__param_t, t in time : sum{d in period : (d, t) in dt} 1} :=
        + if (p, sink, param, t) in process__sink__param__time
		  then pt_process_sink[p, sink, param, t]
          else if (p, source, param, t) in process__source__param__time
		  then pt_process_source[p, source, param, t]
		  else if (p, param, t) in connection__param__time
		  then pt_process[p, param, t]
		  else if (p, source, param) in process__source__param
		  then p_process_source[p, source, param]
		  else if (p, sink, param) in process__sink__param
		  then p_process_sink[p, sink, param]
		  else if (p, param) in connection__param
		  then p_process[p, param]
		  else 0;


param ptProcess__source__sink__t_varCost {(p, source, sink) in process_source_sink, t in time : sum{d in period : (d, t) in dt} 1} :=
  + (if (p, source) in process_source then ptProcess_source[p, source, 'variable_cost', t])
  + (if (p, sink) in process_sink then ptProcess_sink[p, sink, 'variable_cost', t])
  + (if (p, source, sink) in process_source_sink then ptProcess[p, 'variable_cost', t])
;

param ptProcess__source__sink__t_varCost_alwaysProcess {(p, source, sink) in process_source_sink_alwaysProcess, t in time : sum{d in period : (d, t) in dt} 1} :=
  + (if (p, source) in process_source then ptProcess_source[p, source, 'variable_cost', t])
  + (if (p, sink) in process_sink then ptProcess_sink[p, sink, 'variable_cost', t])
  + (if (p, source, sink) in process_source_sink then ptProcess[p, 'variable_cost', t])
;

param p_process_source_coefficient {(p, source) in process_source} := 
   p_process_source[p, source, 'coefficient'] ;
#    + if (p_process_source[p, source, 'coefficient']) 
#	  then p_process_source[p, source, 'coefficient'] 
#	  else 1;
param p_process_sink_coefficient {(p, sink) in process_sink} := 
   p_process_sink[p, sink, 'coefficient'];
#	+ if (p_process_sink[p, sink, 'coefficient']) 
#	  then p_process_sink[p, sink, 'coefficient'] 
#	  else 1;

param pt_profile {profile, time};

set reserve__upDown__group__reserveParam__time dimen 5 within {reserve, upDown, group, reserveTimeParam, time};
param p_reserve_upDown_group {reserve, upDown, group, reserveParam} default 0;
param pt_reserve_upDown_group {reserve, upDown, group, reserveTimeParam, time};
param ptReserve_upDown_group {(r, ud, g) in reserve__upDown__group, param in reserveTimeParam, t in time} :=
        + if (r, ud, g, param, t) in reserve__upDown__group__reserveParam__time
		  then pt_reserve_upDown_group[r, ud, g, param, t]
		  else p_reserve_upDown_group[r, ud, g, param];
param p_process_reserve_upDown_node {process, reserve, upDown, node, reserveParam} default 0;
set process_reserve_upDown_node_active := {(p, r, ud, n) in process_reserve_upDown_node : sum{(r, ud, g) in reserve__upDown__group} 1};
set prundt := {(p, r, ud, n) in process_reserve_upDown_node_active, (d, t) in period_time};

param p_constraint_constant {constraint};
param p_process_node_constraint_coefficient {process, node, constraint};
param penalty_up {n in nodeBalance};
param penalty_down {n in nodeBalance};
param step_duration{(d, t) in dt};
param hours_in_period{d in period} := sum {(d, t) in dt} (step_duration[d, t]);
param hours_in_solve := sum {(d, t) in dt} (step_duration[d, t]);
param period_share_of_year{d in period} := hours_in_period[d] / 8760;
param solve_share_of_year := hours_in_solve / 8760;
param period_share_of_annual_flow {n in node, d in period : (n, 'scale_to_annual_flow') in node__inflow_method && pdNode[n, 'annual_flow', d]} := 
        abs(sum{(d, t) in dt} (ptNode[n, 'inflow', t])) / pdNode[n, 'annual_flow', d];
param period_flow_multiplier {n in node, d in period : (n, 'scale_to_annual_flow') in node__inflow_method && pdNode[n, 'annual_flow', d]} := 
        period_share_of_year[d] / period_share_of_annual_flow[n, d];
param pdtNodeInflow {n in node, (d, t) in dt : (n, 'no_inflow') not in node__inflow_method}  := 
        + ptNode[n, 'inflow', t] *
        ( if (n, 'scale_to_annual_flow') in node__inflow_method && pdNode[n, 'annual_flow', d] then
		    + period_flow_multiplier[n, d]
		  else 1);

param step_period{(d, t) in dt} := 0;
param ed_entity_annual{e in entityInvest, d in period_invest} :=
        + sum{m in invest_method : (e, m) in entity__invest_method && e in node && m not in invest_method_not_allowed}
          ( + (pdNode[e, 'invest_cost', d] * 1000 * ( pdNode[e, 'interest_rate', d] 
			  / (1 - (1 / (1 + pdNode[e, 'interest_rate', d])^pdNode[e, 'lifetime', d] ) ) ))
			+ pdNode[e, 'fixed_cost', d] * 1000
		  )
        + sum{m in invest_method : (e, m) in entity__invest_method && e in process && m not in invest_method_not_allowed}
		  (
            + (pdProcess[e, 'invest_cost', d] * 1000 * ( pdProcess[e, 'interest_rate', d] 
			  / (1 - (1 / (1 + pdProcess[e, 'interest_rate', d])^pdProcess[e, 'lifetime', d] ) ) ))
			+ pdProcess[e, 'fixed_cost', d] * 1000
		  )
; 			

param ptProcess_section{p in process, t in time : (p, 'min_load_efficiency') in process_ct_method} := 
        + 1 / ptProcess[p, 'efficiency', t] 
    	- ( 1 / ptProcess[p, 'efficiency', t] - ptProcess[p, 'min_load', t] / ptProcess[p, 'efficiency_at_min_load', t] ) 
			    / (1 - ptProcess[p, 'min_load', t])
		; 
param ptProcess_slope{p in process, t in time : (p, 'min_load_efficiency') in process_ct_method} := 
        1 / ptProcess[p, 'efficiency', t] - ptProcess_section[p, t];


set ed_invest := {e in entityInvest, d in period_invest : ed_entity_annual[e, d]};
set pd_invest := {(p, d) in ed_invest : p in process};
set nd_invest := {(n, d) in ed_invest : n in node};
set ed_divest := ed_invest;

param e_invest_max_total{e in entityInvest} :=
  + (if e in process then p_process[e, 'invest_max_total'])
  + (if e in node then p_node[e, 'invest_max_total'])
;  

param e_invest_min_total{e in entityInvest} :=
  + (if e in process then p_process[e, 'invest_min_total'])
  + (if e in node then p_node[e, 'invest_min_total'])
;  

param ed_invest_max_period{(e, d) in ed_invest} :=
  + (if e in process then pdProcess[e, 'invest_max_period', d])
  + (if e in node then pdNode[e, 'invest_max_period', d])
;  

param ed_invest_min_period{(e, d) in ed_invest} :=
  + (if e in process then pdProcess[e, 'invest_min_period', d])
  + (if e in node then pdNode[e, 'invest_min_period', d])
;  

set process_source_sink_ramp_limit_up :=
    {(p, source, sink) in process_source_sink
	    : ( sum{(p, source, m) in process_node_ramp_method : m in ramp_limit_method} 1
		    && p_process_source[p, source, 'ramp_speed_up'] > 0
		  ) || 
		  ( sum{(p, sink, m) in process_node_ramp_method : m in ramp_limit_method} 1
		    && p_process_sink[p, sink, 'ramp_speed_up'] > 0
		  )
	};
set process_source_sink_ramp_limit_down :=
    {(p, source, sink) in process_source_sink
	    : ( sum{(p, source, m) in process_node_ramp_method : m in ramp_limit_method} 1
		    && p_process_source[p, source, 'ramp_speed_down'] > 0
		  ) ||
		  ( sum{(p, sink, m) in process_node_ramp_method : m in ramp_limit_method} 1
		    && p_process_sink[p, sink, 'ramp_speed_down'] > 0
		  )
	};
set process_source_sink_ramp_cost :=
    {(p, source, sink) in process_source_sink
	    : sum{(p, source, m) in process_node_ramp_method : m in ramp_cost_method} 1
		  || sum{(p, sink, m) in process_node_ramp_method : m in ramp_cost_method} 1
	};
set process_source_sink_ramp :=
    process_source_sink_ramp_limit_up 
	union process_source_sink_ramp_limit_down 
	union process_source_sink_ramp_cost;

set process_source_sink_dt_ramp_up :=
        {(p, source, sink) in process_source_sink_ramp_limit_up, (d, t) in dt :
 		    p_process[p, 'ramp_speed_up'] * 60 < step_duration[d, t]
        };
set process_source_sink_dt_ramp_down :=
        {(p, source, sink) in process_source_sink_ramp_limit_down, (d, t) in dt :
 		    p_process[p, 'ramp_speed_down'] * 60 < step_duration[d, t]
		};
set process_source_sink_dt_ramp :=
        {(p, source, sink) in process_source_sink_ramp, (d, t) in dt :
		    (p, source, sink) in process_source_sink_ramp_cost
		    || (p, source, sink, d, t) in process_source_sink_dt_ramp_down
            || (p, source, sink, d, t) in process_source_sink_dt_ramp_up
        };

set process_reserve_upDown_node_increase_reserve_ratio :=
        {(p, r, ud, n) in process_reserve_upDown_node_active :
		    p_process_reserve_upDown_node[p, r, ud, n, 'increase_reserve_ratio'] > 0
		};

set group_commodity_node_period_co2 :=
        {g in group, (c, n) in commodity_node, d in period : 
		    (g, n) in group_node 
			&& p_commodity[c, 'co2_content'] 
			&& pdGroup[g, 'co2_price', d]
		};

set process__sink_nonSync_unit dimen 2 within {process, node};
set process_nonSync_connection dimen 1 within {process};
set process__sink_nonSync :=
        {p in process, sink in node :
		       ( (p, sink) in process_sink && (p, sink) in process__sink_nonSync_unit )
			|| ( (p, sink) in process_sink && p in process_nonSync_connection )
			|| ( (p, sink) in process_source && p in process_nonSync_connection )  
	    };

param p_entity_invested {e in entity : e in entityInvest};
param p_entity_all_existing {e in entity} :=
        + (if e in process then p_process[e, 'existing'])
        + (if e in node then p_node[e, 'existing'])
		+ (if not p_model['solveFirst'] && e in entityInvest then p_entity_invested[e])
;


set process_VRE := {p in process_unit : not (sum{(p, source) in process_source} 1)
                                        && (sum{(p, n, prof, m) in process__node__profile__profile_method : m = 'upper_limit'} 1)};

param d_obj default 0;
param d_flow {(p, source, sink, d, t) in peedt} default 0;
param d_flow_1_or_2_variable {(p, source, sink, d, t) in peedt} default 0;
param d_flowInvest {(p, d) in pd_invest} default 0;
param d_reserve_upDown_node {(p, r, ud, n, d, t) in prundt} default 0;
param dq_reserve {(r, ud, ng) in reserve__upDown__group, (d, t) in dt} default 0;

#########################
# Read data
#table data IN 'CSV' '.csv' :  <- [];

# Domain sets
table data IN 'CSV' 'input/commodity.csv' : commodity <- [commodity];
table data IN 'CSV' 'input/constraint__sense.csv' : constraint <- [constraint];
table data IN 'CSV' 'input/debug.csv': debug <- [debug];
table data IN 'CSV' 'input/entity.csv': entity <- [entity];
table data IN 'CSV' 'input/group.csv' : group <- [group];
table data IN 'CSV' 'input/node.csv' : node <- [node];
table data IN 'CSV' 'input/nodeBalance.csv' : nodeBalance <- [nodeBalance];
table data IN 'CSV' 'input/nodeState.csv' : nodeState <- [nodeState];
table data IN 'CSV' 'input/groupInertia.csv' : groupInertia <- [groupInertia];
table data IN 'CSV' 'input/groupNonSync.csv' : groupNonSync <- [groupNonSync];
table data IN 'CSV' 'input/groupCapacityMargin.csv' : groupCapacityMargin <- [groupCapacityMargin];
table data IN 'CSV' 'input/groupOutput.csv' : groupOutput <- [groupOutput];
table data IN 'CSV' 'input/process.csv': process <- [process];
table data IN 'CSV' 'input/profile.csv': profile <- [profile];
table data IN 'CSV' 'input/timeline.csv' : time <- [timestep];

# Single dimension membership sets
table data IN 'CSV' 'input/process_connection.csv': process_connection <- [process_connection];
table data IN 'CSV' 'input/process_nonSync_connection.csv': process_nonSync_connection <- [process];
table data IN 'CSV' 'input/process_unit.csv': process_unit <- [process_unit];

# Multi dimension membership sets
table data IN 'CSV' 'input/commodity__node.csv' : commodity_node <- [commodity,node];
table data IN 'CSV' 'input/entity__invest_method.csv' : entity__invest_method <- [entity,invest_method];
table data IN 'CSV' 'input/node__inflow_method.csv' : node__inflow_method <- [node,inflow_method];
table data IN 'CSV' 'input/group__node.csv' : group_node <- [group,node];
table data IN 'CSV' 'input/group__process.csv' : group_process <- [group,process];
table data IN 'CSV' 'input/group__process__node.csv' : group_process_node <- [group,process,node];
table data IN 'CSV' 'input/p_process_node_constraint_coefficient.csv' : process_node_constraint <- [process, node, constraint];
table data IN 'CSV' 'input/constraint__sense.csv' : constraint__sense <- [constraint, sense];
table data IN 'CSV' 'input/p_process.csv' : process__param <- [process, processParam];
table data IN 'CSV' 'input/pd_node.csv' : node__param__period <- [node, nodeParam, period];
table data IN 'CSV' 'input/pt_node.csv' : node__param__time <- [node, nodeParam, time];
table data IN 'CSV' 'input/pd_process.csv' : process__param__period <- [process, processParam, period];
table data IN 'CSV' 'input/pt_process.csv' : process__param__time <- [process, processParam, time];
table data IN 'CSV' 'input/p_group.csv' : group__param <- [group, groupParam];
table data IN 'CSV' 'input/pd_group.csv' : group__param__period <- [group, groupParam, period];
table data IN 'CSV' 'input/process__ct_method.csv' : process_ct_method <- [process,ct_method];
table data IN 'CSV' 'input/process__node__ramp_method.csv' : process_node_ramp_method <- [process,node,ramp_method];
table data IN 'CSV' 'input/process__reserve__upDown__node.csv' : process_reserve_upDown_node <- [process,reserve,upDown,node];
table data IN 'CSV' 'input/process__sink.csv' : process_sink <- [process,sink];
table data IN 'CSV' 'input/process__source.csv' : process_source <- [process,source];
table data IN 'CSV' 'input/process__sink_nonSync_unit.csv' : process__sink_nonSync_unit <- [process,sink];
table data IN 'CSV' 'input/process__startup_method.csv' : process_startup_method <- [process,startup_method];
table data IN 'CSV' 'input/process__profile__profile_method.csv' : process__profile__profile_method <- [process,profile,profile_method];
table data IN 'CSV' 'input/process__node__profile__profile_method.csv' : process__node__profile__profile_method <- [process,node,profile,profile_method];
#table data IN 'CSV' 'input/reserve__upDown__group.csv' : reserve__upDown__group <- [reserve,upDown,group];
table data IN 'CSV' 'input/reserve__upDown__group__method.csv' : reserve__upDown__group__method <- [reserve,upDown,group,method];
table data IN 'CSV' 'input/pt_reserve__upDown__group.csv' : reserve__upDown__group__reserveParam__time <- [reserve, upDown, group, reserveParam, time];
table data IN 'CSV' 'input/timeblocks_in_use.csv' : solve_period_timeblockset <- [solve,period,timeblocks];
table data IN 'CSV' 'solve_data/solve_current.csv' : solve_current <- [solve];
table data IN 'CSV' 'input/p_process_source.csv' : process__source__param <- [process, source, sourceSinkParam];
table data IN 'CSV' 'input/pt_process_source.csv' : process__source__param__time <- [process, source, sourceSinkTimeParam, time];
table data IN 'CSV' 'input/p_process_sink.csv' : process__sink__param <- [process, sink, sourceSinkParam];
table data IN 'CSV' 'input/pt_process_sink.csv' : process__sink__param__time <- [process, sink, sourceSinkTimeParam, time];
table data IN 'CSV' 'input/pd_commodity.csv' : commodity__param__period <- [commodity, commodityParam, period];

# Parameters for model data
table data IN 'CSV' 'input/p_commodity.csv' : [commodity, commodityParam], p_commodity;
table data IN 'CSV' 'input/pd_commodity.csv' : [commodity, commodityParam, period], pd_commodity;
table data IN 'CSV' 'input/p_group__process.csv' : [group, process, groupParam], p_group__process;
table data IN 'CSV' 'input/p_group.csv' : [group, groupParam], p_group;
table data IN 'CSV' 'input/pd_group.csv' : [group, groupParam, period], pd_group;
table data IN 'CSV' 'input/p_node.csv' : [node, nodeParam], p_node;
table data IN 'CSV' 'input/pd_node.csv' : [node, nodeParam, period], pd_node;
table data IN 'CSV' 'input/pt_node.csv' : [node, nodeParam, time], pt_node;
table data IN 'CSV' 'input/p_process_node_constraint_coefficient.csv' : [process, node, constraint], p_process_node_constraint_coefficient;
table data IN 'CSV' 'input/p_process__reserve__upDown__node.csv' : [process, reserve, upDown, node, reserveParam], p_process_reserve_upDown_node;
table data IN 'CSV' 'input/p_process_sink.csv' : [process, sink, sourceSinkParam], p_process_sink;
table data IN 'CSV' 'input/pt_process_sink.csv' : [process, sink, sourceSinkTimeParam, time], pt_process_sink;
table data IN 'CSV' 'input/p_process_source.csv' : [process, source, sourceSinkParam], p_process_source;
table data IN 'CSV' 'input/pt_process_source.csv' : [process, source, sourceSinkTimeParam, time], pt_process_source;
table data IN 'CSV' 'input/p_constraint_constant.csv' : [constraint], p_constraint_constant;
table data IN 'CSV' 'input/p_process.csv' : [process, processParam], p_process;
table data IN 'CSV' 'input/pd_process.csv' : [process, processParam, period], pd_process;
table data IN 'CSV' 'input/pt_process.csv' : [process, processParam, time], pt_process;
table data IN 'CSV' 'input/pt_profile.csv' : [profile, time], pt_profile;
table data IN 'CSV' 'input/p_reserve__upDown__group.csv' : [reserve, upDown, group, reserveParam], p_reserve_upDown_group;
table data IN 'CSV' 'input/pt_reserve__upDown__group.csv' : [reserve, upDown, group, reserveParam, time], pt_reserve_upDown_group;

# Parameters from the solve loop
table data IN 'CSV' 'solve_data/steps_in_use.csv' : dt <- [period, step];
table data IN 'CSV' 'solve_data/steps_in_use.csv' : [period, step], step_duration;
table data IN 'CSV' 'solve_data/steps_in_timeline.csv' : period_time <- [period,step];
table data IN 'CSV' 'solve_data/step_previous.csv' : dttt <- [period, time, previous, previous_within_block];
table data IN 'CSV' 'solve_data/realized_periods_of_current_solve.csv' : period_realized <- [period];
table data IN 'CSV' 'solve_data/invest_periods_of_current_solve.csv' : period_invest <- [period];
table data IN 'CSV' 'input/p_model.csv' : [modelParam], p_model;

# After rolling forward the investment model
table data IN 'CSV' 'solve_data/p_entity_invested.csv' : [entity], p_entity_invested;

#########################
# Variable declarations
var v_flow {(p, source, sink, d, t) in peedt};
var v_ramp {(p, source, sink, d, t) in peedt};
var v_reserve {(p, r, ud, n, d, t) in prundt : sum{(r, ud, g) in reserve__upDown__group} 1 } >= 0;
var v_state {n in nodeState, (d, t) in dt} >= 0;
var v_online_linear {p in process_online,(d, t) in dt} >=0;
var v_startup_linear {p in process_online, (d, t) in dt} >=0;
var v_shutdown_linear {p in process_online, (d, t) in dt} >=0;
var v_invest {(e, d) in ed_invest} >= 0;
var v_divest {(e, d) in ed_divest} >= 0;
var vq_state_up {n in nodeBalance, (d, t) in dt} >= 0;
var vq_state_down {n in nodeBalance, (d, t) in dt} >= 0;
var vq_reserve {(r, ud, ng) in reserve__upDown__group, (d, t) in dt} >= 0;
var vq_inertia {g in groupInertia, (d, t) in dt} >= 0;
var vq_non_synchronous {g in groupNonSync, (d, t) in dt} >= 0;
#var vq_online_linear_pos {p in process_online, (d, t) in dt} >=0;
#var vq_online_linear_neg {p in process_online, (d, t) in dt} >=0;


#########################
## Data checks 
printf 'Checking: Eff. data for 1 variable conversions directly from source to sink (and possibly back)\n';
check {(p, m) in process_method, t in time : m in method_1var} ptProcess[p, 'efficiency', t] != 0 ;

printf 'Checking: Efficiency data for 1-way conversions with an online variable\n';
check {(p, m) in process_method, t in time : m in method_1way_on} ptProcess[p, 'efficiency', t] != 0;

printf 'Checking: Efficiency data for 2-way linear conversions without online variables\n';
check {(p, m) in process_method, t in time : m in method_2way_off} ptProcess[p, 'efficiency', t] != 0;

printf 'Checking: Invalid combinations between conversion/transfer methods and the startup method\n';
check {(p, ct_m, s_m, f_m, m) in process_ct_startup_fork_method} : not (p, ct_m, s_m, f_m, 'not_applicable') in process_ct_startup_fork_method;
#display commodity_node, process_source_sink, process_source, process_sink;
#display ptProcess__source__sink__t_varCost, ptProcess__source__sink__t_varCost_alwaysProcess;
minimize total_cost:
  + sum {(d, t) in dt}
    (
      + sum {(c, n) in commodity_node} pdCommodity[c, 'price', d]
	      * (
		      # Buying a commodity (increases the objective function)
	          + sum {(p, n, sink) in process_source_sink_noEff } 
			    ( + v_flow[p, n, sink, d, t] )
	          + sum {(p, n, sink) in process_source_sink_eff } (
			      + v_flow[p, n, sink, d, t]
         	          * (if (p, 'min_load_efficiency') in process_ct_method then ptProcess_slope[p, t] else 1 / ptProcess[p, 'efficiency', t])
                  + (if (p, 'min_load_efficiency') in process_ct_method then 
	                  + v_online_linear[p, d, t] 
			              * ptProcess_section[p, t]
				          * p_entity_unitsize[p]
					)	  
				)		  
			  # Selling to a commodity node (decreases objective function if price is positive)
	          - sum {(p, source, n) in process_source_sink } (
			      + v_flow[p, source, n, d, t]
				)  
		    )
	  + sum {(g, c, n, d) in group_commodity_node_period_co2} p_commodity[c, 'co2_content'] * pdGroup[g, 'co2_price', d] 
	      * (
		      # Paying for CO2 (increases the objective function)
			  + sum {(p, n, sink) in process_source_sink_noEff } 
			    ( + v_flow[p, n, sink, d, t] )
	          + sum {(p, n, sink) in process_source_sink_eff } (
			      + v_flow[p, n, sink, d, t]
         	          * (if (p, 'min_load_efficiency') in process_ct_method then ptProcess_slope[p, t] else 1 / ptProcess[p, 'efficiency', t])
                  + (if (p, 'min_load_efficiency') in process_ct_method then 
	                  + v_online_linear[p, d, t] 
			              * ptProcess_section[p, t]
				          * p_entity_unitsize[p]
					)	  
				)		  
			  # Receiving credits for removing CO2 (decreases the objective function)
	          - sum {(p, source, n) in process_source_sink } (
			      + v_flow[p, source, n, d, t]
				)  
			)
 	 + sum {p in process_online : pdProcess[p, 'startup_cost', d]} (v_startup_linear[p, d, t] * pdProcess[p, 'startup_cost', d])
     + sum {(p, source, sink) in process_source_sink_noEff : ptProcess__source__sink__t_varCost[p, source, sink, t]}
       ( + ptProcess__source__sink__t_varCost[p, source, sink, t]
	       * v_flow[p, source, sink, d, t]
       )         			 
     + sum {(p, source, sink) in process_source_sink_eff : ptProcess__source__sink__t_varCost[p, source, sink, t]}
	   ( + ptProcess__source__sink__t_varCost[p, source, sink, t]
	       * ( + v_flow[p, source, sink, d, t]
           	       * (if (p, 'min_load_efficiency') in process_ct_method then ptProcess_slope[p, t] else 1 / ptProcess[p, 'efficiency', t])
               + (if (p, 'min_load_efficiency') in process_ct_method then 
	               + v_online_linear[p, d, t] 
   			          * ptProcess_section[p, t]
			          * p_entity_unitsize[p]
    			 )	  
			 )
	   ) 
#	  + sum {(p, source, 'variable_cost') in process__source__timeParam} 
#       ( + ptProcess_source[p, source, 'variable_cost', t]
#	          * ( + sum {(p, source, sink) in process_source_sink, m in method : (p, m) in process_method && m in method_1var_per_way} (
#		              + v_flow[p, source, sink, d, t]
#         	              * (if (p, 'min_load_efficiency') in process_ct_method then ptProcess_slope[p, t] else 1 / ptProcess[p, 'efficiency', t])
#                      + (if (p, 'min_load_efficiency') in process_ct_method then 
#	                      + v_online_linear[p, d, t] 
#   			                  * ptProcess_section[p, t]
#			                  * p_entity_unitsize[p]
#    				    )	  
#					)	
# 	              + sum {(p, source, sink) in process_source_sink, m in method : (p, m) in process_method && m not in method_1var_per_way} (
#				      + v_flow[p, source, sink, d, t]
#					)  
#                )
#       )
#	  + sum {(p, sink, 'variable_cost') in process__sink__timeParam} 
#       ( + ptProcess_sink[p, sink, 'variable_cost', t]
#		      * ( + sum {(p, source, sink) in process_source_sink, m in method : (p, m) in process_method} (
#				      + v_flow[p, source, sink, d, t]
#					)  
#                )
#       )
#	  + sum {(p, 'variable_cost') in process__timeParam : p in process_connection} 
#       ( + ptProcess[p, 'variable_cost', t]
#		      * sum {(p, source, sink) in process_source_sink}
#			      + v_flow[p, source, sink, d, t]
#       )
#      + sum {(p, source, sink, m) in process__source__sink__ramp_method : m in ramp_cost_method}
#        ( + v_ramp[p, source, sink, d, t] * pProcess_source_sink[p, source, sink, 'ramp_cost'] )
      + sum {g in groupInertia} vq_inertia[g, d, t] * pdGroup[g, 'penalty_inertia', d]
      + sum {g in groupNonSync} vq_non_synchronous[g, d, t] * pdGroup[g, 'penalty_non_synchronous', d]
      + sum {n in nodeBalance} vq_state_up[n, d, t] * ptNode[n, 'penalty_up', t]
      + sum {n in nodeBalance} vq_state_down[n, d, t] * ptNode[n, 'penalty_down', t]
      + sum {(r, ud, ng) in reserve__upDown__group} vq_reserve[r, ud, ng, d, t] * p_reserve_upDown_group[r, ud, ng, 'penalty_reserve']
#      + sum {p in process_online} vq_online_linear_pos[p, d, t] * 1000000
#      + sum {p in process_online} vq_online_linear_neg[p, d, t] * 1000000
	) * step_duration[d, t]
	  / period_share_of_year[d]
  + sum {(e, d) in ed_invest} v_invest[e, d]
    * p_entity_unitsize[e]
    * ed_entity_annual[e, d]
;

# Energy balance in each node  
s.t. nodeBalance_eq {n in nodeBalance, (d, t, t_previous, t_previous_within_block) in dttt} :
  + (if n in nodeState then (v_state[n, d, t] -  v_state[n, d, t_previous]))
  =
  # n is sink
  + sum {(p, source, n) in process_source_sink} (
      + v_flow[p, source, n, d, t]
	)  
  # n is source
  - sum {(p, n, sink) in process_source_sink_eff } ( 
      + v_flow[p, n, sink, d, t] 
	      * (if (p, 'min_load_efficiency') in process_ct_method then ptProcess_slope[p, t] else 1 / ptProcess[p, 'efficiency', t])
      + (if (p, 'min_load_efficiency') in process_ct_method then 
#	        + (v_online_linear[p, d, t] + vq_online_linear_pos[p, d, t] - vq_online_linear_neg[p, d, t])
	        + v_online_linear[p, d, t]
			    * ptProcess_section[p, t]
				* p_entity_unitsize[p]
		)
    )		
  - sum {(p, n, sink) in process_source_sink_noEff} 
    ( + v_flow[p, n, sink, d, t] 
    )
  + (if (n, 'no_inflow') not in node__inflow_method then pdtNodeInflow[n, d, t])
  - (if n in nodeSelfDischarge then 
      + v_state[n, d, t] 
	      * ptNode[n, 'self_discharge_loss', t] 
		  * step_duration[d, t])
  + vq_state_up[n, d, t]
  - vq_state_down[n, d, t]
;

s.t. reserveBalance_timeseries_eq {(r, ud, ng, r_m) in reserve__upDown__group__method, (d, t) in dt : r_m = 'timeseries_only' || r_m = 'both'} :
  + sum {(p, r, ud, n) in process_reserve_upDown_node_active 
	      :  (sum{(p, m) in process_method : m not in method_1var_per_way} 1 || (p, n) in process_sink)
		  && (ng, n) in group_node 
		  && (r, ud, ng) in reserve__upDown__group} 
	    ( v_reserve[p, r, ud, n, d, t] 
	      * p_process_reserve_upDown_node[p, r, ud, n, 'reliability']
	    )
  + sum {(p, r, ud, n) in process_reserve_upDown_node_active  
		  :  (sum{(p, m) in process_method : m in method_1var_per_way} 1 && (p, n) in process_source)
		  && (ng, n) in group_node 
		  && (r, ud, ng) in reserve__upDown__group} 
	    ( v_reserve[p, r, ud, n, d, t] 
	      * p_process_reserve_upDown_node[p, r, ud, n, 'reliability']
	          * (if (p, 'min_load_efficiency') in process_ct_method then ptProcess_slope[p, t] else 1 / ptProcess[p, 'efficiency', t])
		)
  + vq_reserve[r, ud, ng, d, t]
  >=
  + ptReserve_upDown_group[r, ud, ng, 'reservation', t]
;

s.t. reserveBalance_dynamic_eq{(r, ud, ng, r_m) in reserve__upDown__group__method, (d, t) in dt : r_m = 'dynamic_only' || r_m = 'both'} :
  + sum {(p, r, ud, n) in process_reserve_upDown_node_active 
	      : sum{(p, m) in process_method : m in method_1var_per_way} 1
		  && (ng, n) in group_node 
		  && (r, ud, ng) in reserve__upDown__group} 
	    ( v_reserve[p, r, ud, n, d, t] 
	      * p_process_reserve_upDown_node[p, r, ud, n, 'reliability']
	    )
  + sum {(p, r, ud, n) in process_reserve_upDown_node_active
		  : sum{(p, m) in process_method : m not in method_1var_per_way} 1
		  && (ng, n) in group_node 
		  && (r, ud, ng) in reserve__upDown__group} 
	    ( v_reserve[p, r, ud, n, d, t] 
	      * p_process_reserve_upDown_node[p, r, ud, n, 'reliability']
	          * (if (p, 'min_load_efficiency') in process_ct_method then ptProcess_slope[p, t] else 1 / ptProcess[p, 'efficiency', t])
		)
  + vq_reserve[r, ud, ng, d, t]
  >=
  + sum {(p, r, ud, n) in process_reserve_upDown_node_increase_reserve_ratio : (ng, n) in group_node 
          && (r, ud, ng) in reserve__upDown__group}
	   (v_reserve[p, r, ud, n, d, t] * p_process_reserve_upDown_node[p, r, ud, n, 'increase_reserve_ratio'])
  + sum {(n, ng) in group_node : p_reserve_upDown_group[r, ud, ng, 'increase_reserve_ratio']}
	   (pdtNodeInflow[n, d, t] * p_reserve_upDown_group[r, ud, ng, 'increase_reserve_ratio'])
;

# Indirect efficiency conversion - there is more than one variable. Direct conversion does not have an equation - it's directly in the nodeBalance_eq.
s.t. conversion_indirect {(p, m) in process_method, (d, t) in dt : m in method_indirect} :
  + sum {source in entity : (p, source) in process_source} 
    ( + v_flow[p, source, p, d, t] 
  	      * p_process_source_coefficient[p, source]
	)
  =
  + sum {sink in entity : (p, sink) in process_sink} 
    ( + v_flow[p, p, sink, d, t] 
	      * p_process_sink_coefficient[p, sink]
	)
	  * (if (p, 'min_load_efficiency') in process_ct_method then ptProcess_slope[p, t] else 1 / ptProcess[p, 'efficiency', t])
  + (if (p, 'min_load_efficiency') in process_ct_method then v_online_linear[p, d, t] * ptProcess_section[p, t] * p_entity_unitsize[p])
;

s.t. profile_upper_limit {(p, source, sink, f, m) in process__source__sink__profile__profile_method, (d, t) in dt : m = 'upper_limit'} :
  + ( + v_flow[p, source, sink, d, t] 
  	      * ( if (p, source) in process_source then p_process_source_coefficient[p, source]
			  else if (p, sink) in process_sink then p_process_sink_coefficient[p, sink]
			  else 1
			)
	)
  <=
  + pt_profile[f, t]
    * ( + ( if p not in process_online then
              + p_entity_all_existing[p]
              + sum {(p, d_invest) in pd_invest : d_invest <= d} v_invest[p, d_invest] * p_entity_unitsize[p]
#              - sum {(p, d_invest) in pd_divest : d_invest <= d} v_divest[p, d_invest] * p_entity_unitsize[p]
#              - sum {(p, d_invest) in pd_divest : d_invest <= d} v_divest[p, d_invest] * p_entity_unitsize[p]
	      )
        + ( if p in process_online then
              + v_online_linear[p, d, t] * p_entity_unitsize[p]
	      )
      )
;

s.t. profile_lower_limit {(p, source, sink, f, m) in process__source__sink__profile__profile_method, (d, t) in dt : m = 'lower_limit'} :
  + ( + v_flow[p, source, sink, d, t] 
  	      * ( if (p, source) in process_source then p_process_source_coefficient[p, source]
			  else if (p, sink) in process_sink then p_process_sink_coefficient[p, sink]
			  else 1
			)
	)
  >=
  + pt_profile[f, t]
    * ( + ( if p not in process_online then
              + p_entity_all_existing[p]
              + sum {(p, d_invest) in pd_invest : d_invest <= d} v_invest[p, d_invest] * p_entity_unitsize[p]
#              - sum {(p, d_invest) in pd_divest : d_invest <= d} v_divest[p, d_invest] * p_entity_unitsize[p]
	      )
        + ( if p in process_online then
              + v_online_linear[p, d, t] * p_entity_unitsize[p]
	      )
	  )
;

s.t. profile_fixed_limit {(p, source, sink, f, m) in process__source__sink__profile__profile_method, (d, t) in dt : m = 'fixed'} :
  + ( + v_flow[p, source, sink, d, t] 
  	      * ( if (p, source) in process_source then p_process_source_coefficient[p, source]
			  else if (p, sink) in process_sink then p_process_sink_coefficient[p, sink]
			  else 1
			)
	)
  =
  + pt_profile[f, t]
    * ( + ( if p not in process_online then
              + p_entity_all_existing[p]
              + sum {(p, d_invest) in pd_invest : d_invest <= d} v_invest[p, d_invest] * p_entity_unitsize[p]
#              - sum {(p, d_invest) in pd_divest : d_invest <= d} v_divest[p, d_invest] * p_entity_unitsize[p]
	      )
        + ( if p in process_online then
              + v_online_linear[p, d, t] * p_entity_unitsize[p]
	    )
	  )
;

s.t. process_constraint_greater_than {(c, s) in constraint__sense, (d, t) in dt 
     : s in sense_greater_than} :
  + sum {(p, source, sink) in process_source_sink : (p, source, c) in process_node_constraint}
    ( + v_flow[p, source, sink, d, t]
	      * p_process_node_constraint_coefficient[p, source, c]
	)
  + sum {(p, source, sink) in process_source_sink : (p, sink, c) in process_node_constraint}
    ( + v_flow[p, source, sink, d, t]
	      * p_process_node_constraint_coefficient[p, sink, c]
	)
  >=
  + p_constraint_constant[c]
;
	
s.t. process_constraint_less_than {(c, s) in constraint__sense, (d, t) in dt 
     : s in sense_less_than} :
  + sum {(p, source, sink) in process_source_sink : (p, source, c) in process_node_constraint}
    ( + v_flow[source, source, p, d, t]
	      * p_process_node_constraint_coefficient[p, source, c]
	)
  + sum {(p, source, sink) in process_source_sink : (p, sink, c) in process_node_constraint}
    ( + v_flow[p, source, sink, d, t]
	      * p_process_node_constraint_coefficient[p, sink, c]
	)
  <=
  + p_constraint_constant[c]
;

s.t. process_constraint_equal {(c, s) in constraint__sense, (d, t) in dt 
     : s in sense_equal} :
  + sum {(p, source, sink) in process_source_sink : (p, source, c) in process_node_constraint}
    ( + v_flow[p, source, sink, d, t]
	      * p_process_node_constraint_coefficient[p, source, c]
	)
  + sum {(p, source, sink) in process_source_sink : (p, sink, c) in process_node_constraint}
    ( + v_flow[p, source, sink, d, t]
	      * p_process_node_constraint_coefficient[p, sink, c]
	)
  =
  + p_constraint_constant[c]
;

s.t. maxToSink {(p, source, sink) in process_source_sink, (d, t) in dt 
     : (p, sink) in process_sink } :
  + v_flow[p, source, sink, d, t]
  + sum {r in reserve : (p, r, 'up', sink) in process_reserve_upDown_node_active} v_reserve[p, r, 'up', sink, d, t]
  <=
  + ( if p not in process_online then
      + p_process_sink_coefficient[p, sink]
        * ( + p_entity_all_existing[p]
            + sum {(p, d_invest) in pd_invest : d_invest <= d} v_invest[p, d_invest] * p_entity_unitsize[p]
#            - sum {(p, d_invest) in pd_divest : d_invest <= d} v_divest[p, d_invest] * p_entity_unitsize[p]
	      )	
	)
  + ( if p in process_online then
      + p_process_sink_coefficient[p, sink]
        * v_online_linear[p, d, t]
		* p_entity_unitsize[p]
    ) 
;

s.t. minToSink {(p, source, sink) in process_source_sink, (d, t) in dt
     : (p, sink) in process_sink 
	 && sum{(p,m) in process_method : m not in method_2way_1var} 1 
} :
  + v_flow[p, source, sink, d, t]
  >=
  + 0
;

# Special equation to limit the 1variable connection on the negative transfer
s.t. minToSink_1var {(p, source, sink) in process_source_sink, (d, t) in dt
     : (p, sink) in process_sink 
	 && sum{(p,m) in process_method : m in method_2way_1var} 1 
} :
  + v_flow[p, source, sink, d, t]
  >=
  - ( if p not in process_online then
      + p_process_sink_coefficient[p, sink] 
        * ( + p_entity_all_existing[p]
            + sum {(p, d_invest) in pd_invest : d_invest <= d} v_invest[p, d_invest] * p_entity_unitsize[p]
#            - sum {(p, d_invest) in pd_divest : d_invest <= d} v_divest[p, d_invest] * p_entity_unitsize[p]
	      )	
	)
  - ( if p in process_online then
      + p_process_sink_coefficient[p, sink]
        * v_online_linear[p, d, t] 
		* p_entity_unitsize[p]
    )  
;

# Special equations for the method with 2 variables presenting a direct 2way connection between source and sink (without the process)
s.t. maxToSource {(p, sink, source) in process_sink_toSource, (d, t) in dt} :
  + v_flow[p, sink, source, d, t]
  + sum {r in reserve : (p, r, 'up', source) in process_reserve_upDown_node_active} v_reserve[p, r, 'up', source, d, t]
  <=
  + ( if p not in process_online then
      + p_process_source_coefficient[p, source] 
        * ( + p_entity_all_existing[p]
            + sum {(p, d_invest) in pd_invest : d_invest <= d} v_invest[p, d_invest] * p_entity_unitsize[p]
#            - sum {(p, d_invest) in pd_divest : d_invest <= d} v_divest[p, d_invest] * p_entity_unitsize[p]
	      )	
	)
  + ( if p in process_online then
      + p_process_sink_coefficient[p, sink]
        * v_online_linear[p, d, t] 
		* p_entity_unitsize[p]
    )  
;

s.t. minToSource {(p, source, sink) in process_source_sink, (d, t) in dt
     : (p, sink) in process_sink 
	 && sum{(p,m) in process_method : m in method_2way_2var } 1 
} :
  + v_flow[p, sink, source, d, t]
  >=
  + 0
;

s.t. maxOnline {p in process_online, (d, t) in dt} :
  + v_online_linear[p, d, t]
  <=
  + p_entity_all_existing[p] / p_entity_unitsize[p]
  + sum {(p, d_invest) in pd_invest : d_invest <= d} v_invest[p, d_invest]
#   - sum {(p, d_invest) in pd_divest : d_invest <= d} v_divest[p, d_invest]
;

s.t. online__startup_linear {p in process_online, (d, t, t_previous, t_previous_within_block) in dttt} :
  + v_startup_linear[p, d, t]
  >=
  + v_online_linear[p, d, t] 
  - v_online_linear[p, d, t_previous]
;

s.t. maxStartup {p in process_online, (d, t) in dt} :
  + v_startup_linear[p, d, t]
  <=
  + p_entity_all_existing[p] / p_entity_unitsize[p]
  + sum {(p, d_invest) in pd_invest : d_invest <= d} v_invest[p, d_invest]
;

s.t. online__shutdown_linear {p in process_online, (d, t, t_previous, t_previous_within_block) in dttt} :
  + v_shutdown_linear[p, d, t]
  >=
  - v_online_linear[p, d, t] 
  + v_online_linear[p, d, t_previous]
;

s.t. maxShutdown {p in process_online, (d, t) in dt} :
  + v_shutdown_linear[p, d, t]
  <=
  + p_entity_all_existing[p] / p_entity_unitsize[p]
  + sum {(p, d_invest) in pd_invest : d_invest <= d} v_invest[p, d_invest]
;

#s.t. minimum_downtime {p in process_online, t : p_process[u,'min_downtime'] >= step_duration[t]} :
#  + v_online_linear[p, d, t]
#  <=
#  + p_entity_all_existing[p] / p_entity_unitsize[p]
#  + sum {(p, d_invest) in pd_invest : d_invest <= d} [p, d_invest]
#   - sum {(p, d_invest) in pd_divest : d_invest <= d} v_divest[p, d_invest]
#  - sum{(d, t_) in dt : t_ > t && t_ <= t + p_process[u,'min_downtime'] / time_period_duration} (
#      + v_startup_linear[g, n, u, t_]
#	)
#;

# Minimum operational time
#s.t. minimum_uptime {(g, n, u, t) in gnut : u in unit_online && p_unittype[u,'min_uptime_h'] >= time_period_duration / 60 && t >= p_unittype[u,'min_uptime_h'] * 60 #/ time_period_duration} :
#  + v_online[g, n, u, t]
#  >=
#  + sum{t_ in time_in_use : t_ > t - 1 - p_unittype[u,'min_uptime_h'] * 60 / time_period_duration && t_ < t} (
#      + v_startup_linear[g, n, u, t_]
#	)
#;

s.t. ramp_up_variable {(p, source, sink) in process_source_sink_ramp, (d, t, t_previous, t_previous_within_block) in dttt} :
  + v_ramp[p, source, sink, d, t]
  >=
  + v_flow[p, source, sink, d, t]
  - v_flow[p, source, sink, d, t_previous]
;

s.t. ramp_up_constraint {(p, source, sink) in process_source_sink_ramp_limit_up, (d, t, t_previous, t_previous_within_block) in dttt
		: (p, source, sink, d, t) in process_source_sink_dt_ramp} :
  + v_ramp[p, source, sink, d, t]
  + sum {r in reserve : (p, r, 'up', sink) in process_reserve_upDown_node_active} 
         (v_reserve[p, r, 'up', sink, d, t] / step_duration[d, t])
  <=
  + p_process[p, 'ramp_speed_up']
    * 60
	* step_duration[d, t]
	* ( + if (p, sink) in process_sink then p_process_sink_coefficient[p, sink]
        + if (p, source) in process_source then p_process_source_coefficient[p, source]
      )
    * ( + p_entity_all_existing[p]
	    + ( if (p, d) in ed_invest then v_invest[p, d] * p_entity_unitsize[p] )
#		- ( if (p, d) in ed_divest then v_divest[p, d] * p_entity_unitsize[p] )
	  )
  + ( if p in process_online then v_startup_linear[p, d, t] * p_entity_unitsize[p] )  # To make sure that units can startup despite ramp limits.
;

s.t. ramp_down {(p, source, sink) in process_source_sink_ramp_limit_down, (d, t, t_previous, t_previous_within_block) in dttt
		: (p, source, sink, d, t) in process_source_sink_dt_ramp} :
  + v_ramp[p, source, sink, d, t]
  + sum {r in reserve : (p, r, 'down', sink) in process_reserve_upDown_node_active} 
         (v_reserve[p, r, 'down', sink, d, t] / step_duration[d, t])
  >=
  - p_process[p, 'ramp_speed_down']
    * 60
	* step_duration[d, t]
	* ( + if (p, sink) in process_sink then p_process_sink_coefficient[p, sink]
        + if (p, source) in process_source then p_process_source_coefficient[p, source]
      )
    * ( + p_entity_all_existing[p]
	    + ( if (p, d) in ed_invest then v_invest[p, d] * p_entity_unitsize[p] )
#		- ( if (p, d) in ed_divest then v_divest[p, d] * p_entity_unitsize[p] )
	  )
  - ( if p in process_online then v_shutdown_linear[p, d, t] * p_entity_unitsize[p] )  # To make sure that units can shutdown despite ramp limits.
;
display process_reserve_upDown_node, process_reserve_upDown_node_active, reserve__upDown__group, p_process_reserve_upDown_node, process_online;
s.t. reserve_process_upward{(p, r, ud, n, d, t) in prundt : ud = 'up'} :
  + v_reserve[p, r, ud, n, d, t]
  <=
  ( if p in process_online then
      + v_online_linear[p, d, t] 
	    * p_process_reserve_upDown_node[p, r, ud, n, 'max_share']
		* p_entity_unitsize[p]
    else
      + p_process_reserve_upDown_node[p, r, ud, n, 'max_share'] 
        * (
            + p_entity_all_existing[p]
            + sum {(p, d_invest) in pd_invest : d_invest <= d} v_invest[p, d_invest] * p_entity_unitsize[p]
#            - sum {(p, d_invest) in pd_divest : d_invest <= d} v_divest[p, d_invest] * p_entity_unitsize[p]
          )
    	* ( if (sum{(p, prof, m) in process__profile__profile_method : m = 'upper_limit'} 1) then
	          ( + sum{(p, prof, m) in process__profile__profile_method : m = 'upper_limit'} pt_profile[prof, t] )
	        else 1
	      )
  )
;

s.t. reserve_process_downward{(p, r, ud, n, d, t) in prundt : ud = 'down'} :
  + v_reserve[p, r, ud, n, d, t]
  <=
  + p_process_reserve_upDown_node[p, r, ud, n, 'max_share']
    * ( + sum{(p, source, n) in process_source_sink} v_flow[p, source, n, d, t]
        - ( + p_entity_all_existing[p]
            + sum {(p, d_invest) in pd_invest : d_invest <= d} v_invest[p, d_invest] * p_entity_unitsize[p]
#            - sum {(p, d_invest) in pd_divest : d_invest <= d} v_divest[p, d_invest] * p_entity_unitsize[p]
          ) * ( if (sum{(p, prof, m) in process__profile__profile_method : m = 'lower_limit'} 1) then
	              ( + sum{(p, prof, m) in process__profile__profile_method : m = 'lower_limit'} pt_profile[prof, t] )
	          )
	  )		  
;

s.t. maxInvestGroup_entity_period {g in group, d in period_invest : pdGroup[g, 'invest_max_period', d] } :
  + sum{(g, e) in group_entity : (e, d) in ed_invest} v_invest[e, d] * p_entity_unitsize[e]
  <=
  + pdGroup[g, 'invest_max_period', d]
;

s.t. minInvestGroup_entity_period {g in group, d in period_invest : pdGroup[g, 'invest_min_period', d] } :
  + sum{(g, e) in group_entity : (e, d) in ed_invest} v_invest[e, d] * p_entity_unitsize[e]
  <=
  + pdGroup[g, 'invest_min_period', d]
;

s.t. maxInvestGroup_entity_total {g in group : p_group[g, 'invest_max_total'] } :
  + sum{(g, e) in group_entity, d in period : (e, d) in ed_invest}
    (
      + v_invest[e, d]
      + (if not p_model['solveFirst'] && e in entityInvest then p_entity_invested[e])
	)
  <=
  + p_group[g, 'invest_max_total']
;

s.t. minInvestGroup_entity_total {g in group : p_group[g, 'invest_min_total'] } :
  + sum{(g, e) in group_entity, d in period : (e, d) in ed_invest}
    (
      + v_invest[e, d]
      + (if not p_model['solveFirst'] && e in entityInvest then p_entity_invested[e])
	)
  >=
  + p_group[g, 'invest_min_total']
;

s.t. maxInvest_entity_period {(e, d)  in ed_invest : ed_invest_max_period[e, d]} :  # Covers both processes and nodes
  + v_invest[e, d] * p_entity_unitsize[e] 
  <= 
  + ed_invest_max_period[e, d]
;

s.t. minInvest_entity_period {(e, d)  in ed_invest : ed_invest_min_period[e, d]} :  # Covers both processes and nodes
  + v_invest[e, d] * p_entity_unitsize[e] 
  >= 
  + ed_invest_min_period[e, d]
;

s.t. maxInvest_entity_total {e  in entityInvest : e_invest_max_total[e] && sum{(e, d) in ed_invest} 1} :  # Covers both processes and nodes
  + sum{(e, d) in ed_invest} v_invest[e, d] * p_entity_unitsize[e] 
  <= 
  + e_invest_max_total[e]
  + (if not p_model['solveFirst'] then p_entity_invested[e])
;

s.t. minInvest_entity_total {e  in entityInvest : e_invest_min_total[e] && sum{(e, d) in ed_invest} 1} :  # Covers both processes and nodes
  + sum{(e, d) in ed_invest} v_invest[e, d] * p_entity_unitsize[e] 
  >= 
  + e_invest_min_total[e]
  + (if not p_model['solveFirst'] then p_entity_invested[e])
;

s.t. maxCumulative_flow_solve {g in group : p_group[g, 'max_cumulative_flow']} :
  + sum{(g, p, n) in group_process_node, (d, t) in dt} (
      # n is sink
      + sum {(p, source, n) in process_source_sink} (
          + v_flow[p, source, n, d, t]
	    )  
      # n is source
      - sum {(p, n, sink) in process_source_sink_eff } ( 
          + v_flow[p, n, sink, d, t] 
	           * (if (p, 'min_load_efficiency') in process_ct_method then ptProcess_slope[p, t] else 1 / ptProcess[p, 'efficiency', t])
          + (if (p, 'min_load_efficiency') in process_ct_method then 
	           + v_online_linear[p, d, t] 
		    	    * ptProcess_section[p, t]
			    	* p_entity_unitsize[p]
		    )
        )		
      - sum {(p, n, sink) in process_source_sink_noEff } (
          + v_flow[p, n, sink, d, t] 
		)
	)
	<=
  + p_group[g, 'max_cumulative_flow'] 
      * hours_in_solve
;

s.t. minCumulative_flow_solve {g in group : p_group[g, 'min_cumulative_flow']} :
  + sum{(g, p, n) in group_process_node, (d, t) in dt} (
      # n is sink
      + sum {(p, source, n) in process_source_sink} (
          + v_flow[p, source, n, d, t]
	    )  
      # n is source
      - sum {(p, n, sink) in process_source_sink_eff } ( 
          + v_flow[p, n, sink, d, t] 
	           * (if (p, 'min_load_efficiency') in process_ct_method then ptProcess_slope[p, t] else 1 / ptProcess[p, 'efficiency', t])
          + (if (p, 'min_load_efficiency') in process_ct_method then 
	           + v_online_linear[p, d, t] 
		    	    * ptProcess_section[p, t]
			    	* p_entity_unitsize[p]
		    )
        )		
      - sum {(p, n, sink) in process_source_sink_noEff } (
          + v_flow[p, n, sink, d, t] 
		)  
	)
	>=
  + p_group[g, 'min_cumulative_flow'] 
      * hours_in_solve
;

s.t. maxCumulative_flow_period {g in group, d in period : pd_group[g, 'max_cumulative_flow', d]} :
  + sum{(g, p, n) in group_process_node, (d, t) in dt} (
      # n is sink
      + sum {(p, source, n) in process_source_sink} (
          + v_flow[p, source, n, d, t]
	    )  
      # n is source
      - sum {(p, n, sink) in process_source_sink_eff } ( 
          + v_flow[p, n, sink, d, t] 
	           * (if (p, 'min_load_efficiency') in process_ct_method then ptProcess_slope[p, t] else 1 / ptProcess[p, 'efficiency', t])
          + (if (p, 'min_load_efficiency') in process_ct_method then 
	           + v_online_linear[p, d, t] 
		    	    * ptProcess_section[p, t]
			    	* p_entity_unitsize[p]
		    )
        )		
      - sum {(p, n, sink) in process_source_sink_noEff } (
          + v_flow[p, n, sink, d, t] 
		)
	)   
	<=
  + pd_group[g, 'max_cumulative_flow', d] 
      * hours_in_period[d]
;

s.t. minCumulative_flow_period {g in group, d in period : pd_group[g, 'min_cumulative_flow', d]} :
  + sum{(g, p, n) in group_process_node, (d, t) in dt} (
      # n is sink
      + sum {(p, source, n) in process_source_sink} (
          + v_flow[p, source, n, d, t]
	    )  
      # n is source
      - sum {(p, n, sink) in process_source_sink_eff } ( 
          + v_flow[p, n, sink, d, t] 
	           * (if (p, 'min_load_efficiency') in process_ct_method then ptProcess_slope[p, t] else 1 / ptProcess[p, 'efficiency', t])
          + (if (p, 'min_load_efficiency') in process_ct_method then 
	           + v_online_linear[p, d, t] 
		    	    * ptProcess_section[p, t]
			    	* p_entity_unitsize[p]
		    )
        )		
      - sum {(p, n, sink) in process_source_sink_noEff } (
          + v_flow[p, n, sink, d, t] 
		)
	)
	>=
  + pd_group[g, 'min_cumulative_flow', d] 
      * hours_in_period[d]
;

s.t. maxInstant_flow {g in group, (d, t) in dt : pdGroup[g, 'max_instant_flow', d]} :
  + sum{(g, p, n) in group_process_node} (
      # n is sink
      + sum {(p, source, n) in process_source_sink} (
          + v_flow[p, source, n, d, t]
	    )  
      # n is source
      - sum {(p, n, sink) in process_source_sink_eff } ( 
          + v_flow[p, n, sink, d, t] 
	           * (if (p, 'min_load_efficiency') in process_ct_method then ptProcess_slope[p, t] else 1 / ptProcess[p, 'efficiency', t])
          + (if (p, 'min_load_efficiency') in process_ct_method then 
	           + v_online_linear[p, d, t] 
		    	    * ptProcess_section[p, t]
			    	* p_entity_unitsize[p]
		    )
        )		
      - sum {(p, n, sink) in process_source_sink_noEff } 
          + v_flow[p, n, sink, d, t] 
	)
	<=
  + pdGroup[g, 'max_instant_flow', d] 
;

s.t. minInstant_flow {g in group, (d, t) in dt : pdGroup[g, 'min_instant_flow', d]} :
  + sum{(g, p, n) in group_process_node} (
      # n is sink
      + sum {(p, source, n) in process_source_sink} (
          + v_flow[p, source, n, d, t]
	    )  
      # n is source
      - sum {(p, n, sink) in process_source_sink_eff } ( 
          + v_flow[p, n, sink, d, t] 
	           * (if (p, 'min_load_efficiency') in process_ct_method then ptProcess_slope[p, t] else 1 / ptProcess[p, 'efficiency', t])
          + (if (p, 'min_load_efficiency') in process_ct_method then 
	           + v_online_linear[p, d, t] 
		    	    * ptProcess_section[p, t]
			    	* p_entity_unitsize[p]
		    )
        )		
      - sum {(p, n, sink) in process_source_sink_noEff } 
          + v_flow[p, n, sink, d, t] 
	)
	>=
  + pdGroup[g, 'min_instant_flow', d] 
;

s.t. inertia_constraint {g in groupInertia, (d, t) in dt} :
  + sum {(p, source, sink) in process_source_sink : (p, source) in process_source && (g, source) in group_node && p_process_source[p, source, 'inertia_constant']} 
    ( + (if p in process_online then v_online_linear[p, d, t]) 
	  + (if p not in process_online then v_flow[p, source, sink, d, t])
	) * p_process_source[p, source, 'inertia_constant']
  + sum {(p, source, sink) in process_source_sink : (p, sink) in process_sink && (g, sink) in group_node && p_process_sink[p, sink, 'inertia_constant']} 
    ( + (if p in process_online then v_online_linear[p, d, t]) 
	  + (if p not in process_online then v_flow[p, source, sink, d, t])
    ) * p_process_sink[p, sink, 'inertia_constant']
  + vq_inertia[g, d, t]
  >=
  + pdGroup[g, 'inertia_limit', d]
;

s.t. non_sync_constraint{g in groupNonSync, (d, t) in dt} :
  + sum {(p, source, sink) in process_source_sink : (p, sink) in process__sink_nonSync && (g, sink) in group_node}
    ( + v_flow[p, source, sink, d, t] )
  - vq_non_synchronous[g, d, t]
  <=
  ( + sum {(p, source, sink) in process_source_sink : (p, source) in process_source && (g, source) in group_node} 
        + v_flow[p, source, sink, d, t]
    + sum {(g, n) in group_node} ptNode[n, 'inflow', t]
  ) * pdGroup[g, 'non_synchronous_limit', d]
;

solve;

param entity_all_capacity{e in entity, d in period_realized} :=
  + p_entity_all_existing[e]
  + sum {(e, d_invest) in ed_invest : d <= d_invest} v_invest[e, d_invest].val * p_entity_unitsize[e]
;

param r_process_source_sink_flow_dt{(p, source, sink) in process_source_sink_alwaysProcess, (d, t) in dt} :=
  + sum {(p, m) in process_method : m in method_1var_per_way}
    ( + sum {(p, source, sink2) in process_source_toSink} 
        ( + v_flow[p, source, sink2, d, t].val 
	          * (if (p, 'min_load_efficiency') in process_ct_method then ptProcess_slope[p, t] else 1 / ptProcess[p, 'efficiency', t])
          + (if (p, 'min_load_efficiency') in process_ct_method then v_online_linear[p, d, t] * ptProcess_section[p, t] * p_entity_unitsize[p])
	    )
      + sum {(p, source2, sink) in process_source_toSink} 
          + v_flow[p, source2, sink, d, t].val 
      + sum {(p, source, sink2) in process_sink_toSource} 
        ( + v_flow[p, source, sink2, d, t].val 
	          * (if (p, 'min_load_efficiency') in process_ct_method then ptProcess_slope[p, t] else 1 / ptProcess[p, 'efficiency', t])
          + (if (p, 'min_load_efficiency') in process_ct_method then v_online_linear[p, d, t] * ptProcess_section[p, t] * p_entity_unitsize[p])
	    )
      + sum {(p, source2, sink) in process_sink_toSource} 
          + v_flow[p, source2, sink, d, t].val 
      + (if (p, source, sink) in process__profileProcess__toSink then 
	      + v_flow[p, source, sink, d, t].val)
      + (if (p, source, sink) in process__source__toProfileProcess then 
	      + v_flow[p, source, sink, d, t].val)
   )
  + sum {(p, m) in process_method : m not in method_1var_per_way} (
      + v_flow[p, source, sink, d, t].val 
	)
;

param r_process_source_sink_flow_d{(p, source, sink) in process_source_sink_alwaysProcess, d in period} :=
  + sum {(d, t) in dt} r_process_source_sink_flow_dt[p, source, sink, d, t]
;
param r_process_source_flow_d{(p, source) in process_source, d in period_realized} := 
  + sum {(p, source, sink) in process_source_sink_alwaysProcess, (d, t) in dt} r_process_source_sink_flow_d[p, source, sink, d]
;
param r_process_sink_flow_d{(p, sink) in process_sink, d in period_realized} := 
  + sum {(p, source, sink) in process_source_sink_alwaysProcess, (d, t) in dt} r_process_source_sink_flow_d[p, source, sink, d]
;

param r_nodeState_change_dt{n in nodeState, (d, t_previous) in dt} := sum {(d, t, t_previous, t_previous_within_block) in dttt}
		      (v_state[n, d, t] -  v_state[n, d, t_previous]);
param r_nodeState_change_d{n in nodeState, d in period} := sum {(d, t) in dt} r_nodeState_change_dt[n, d, t];
param r_selfDischargeLoss_dt{n in nodeSelfDischarge, (d, t) in dt} := v_state[n, d, t] * ptNode[n, 'self_discharge_loss', t] * step_duration[d, t];
param r_selfDischargeLoss_d{n in nodeSelfDischarge, d in period} := sum{(d, t) in dt} r_selfDischargeLoss_dt[n, d, t];

param r_cost_commodity_dt{(c, n) in commodity_node, (d, t) in dt} := 
  + step_duration[d, t] 
      * pdCommodity[c, 'price', d] 
      * ( + sum{(p, n, sink) in process_source_sink_alwaysProcess}
              + r_process_source_sink_flow_dt[p, n, sink, d, t]
		  - sum{(p, source, n) in process_source_sink_alwaysProcess}	  
              + r_process_source_sink_flow_dt[p, source, n, d, t]
	    )
;

param r_emissions_co2_dt{(g, c, n, d) in group_commodity_node_period_co2, t in time : (d, t) in dt} := 
  + step_duration[d, t] 
      * p_commodity[c, 'co2_content'] 
      * ( + sum{(p, n, sink) in process_source_sink_alwaysProcess}
              + r_process_source_sink_flow_dt[p, n, sink, d, t]
	      - sum{(p, source, n) in process_source_sink_alwaysProcess}	  
              + r_process_source_sink_flow_dt[p, source, n, d, t]
        )
;	  

param r_emissions_co2_commodity_d{c in commodity, d in period} :=
  + sum{(g, c, n, d) in group_commodity_node_period_co2, t in time : (d, t) in dt} r_emissions_co2_dt[g, c, n, d, t];

param r_cost_co2_dt{(g, c, n, d) in group_commodity_node_period_co2, t in time : (d, t) in dt} := 
  + r_emissions_co2_dt[g, c, n, d, t] 
    * pdGroup[g, 'co2_price', d]
;	  
param r_cost_process_variable_cost_dt{p in process, (d, t) in dt} :=
  + step_duration[d, t]
      * sum{(p, source, sink) in process_source_sink_alwaysProcess}
          + ptProcess__source__sink__t_varCost_alwaysProcess[p, source, sink, t]
	          * r_process_source_sink_flow_dt[p, source, sink, d, t]
#	  * ( + sum {(p, source, sink, 'variable_cost') in process__source__sink__param_t}
#	        ( + sum{(p, n, sink) in process_source_sink_alwaysProcess : (p, sink) in process_sink}
#  			      + ptProcess_source_sink[p, source, sink, 'variable_cost', t]
#		              * r_process_source_sink_flow_dt[p, n, sink, d, t]
#	          + sum{(p, source, n) in process_source_sink_alwaysProcess : (p, source) in process_source}
#  			      + ptProcess_source_sink[p, source, sink, 'variable_cost', t]
#		              * r_process_source_sink_flow_dt[p, source, n, d, t]
#			)
#		)
;
#param r_cost_process_ramp_cost_dt{p in process, (d, t) in dt :
#  sum {(p, source, sink, m) in process__source__sink__ramp_method : m in ramp_cost_method} 1 } :=
#  + step_duration[d, t]
#	  * sum {(p, source, sink, m) in process__source__sink__ramp_method : m in ramp_cost_method} 
#	      + pProcess_source_sink[p, source, sink, 'ramp_cost']
#              * v_ramp[p, source, sink, d, t].val
#;
param r_cost_startup_dt{p in process, (d, t) in dt : p in process_online && pdProcess[p, 'startup_cost', d]} :=
  (v_startup_linear[p, d, t] * pdProcess[p, 'startup_cost', d]);

param r_costPenalty_nodeState_upDown_dt{n in nodeBalance, ud in upDown, (d, t) in dt} :=
  + (if ud = 'up'   then step_duration[d, t] * vq_state_up[n, d, t] * ptNode[n, 'penalty_up', t])
  + (if ud = 'down' then step_duration[d, t] * vq_state_down[n, d, t] * ptNode[n, 'penalty_down', t]) ;

param r_penalty_nodeState_upDown_d{n in nodeBalance, ud in upDown, d in period} :=
  + sum {(d, t) in dt : ud = 'up'} step_duration[d, t] * vq_state_up[n, d, t]
  + sum {(d, t) in dt : ud = 'down'} step_duration[d, t] * vq_state_down[n, d, t] ;

param r_costPenalty_inertia_dt{g in groupInertia, (d, t) in dt} :=
  + step_duration[d, t]
      * vq_inertia[g, d, t] 
	  * pdGroup[g, 'penalty_inertia', d]
;

param r_costPenalty_non_synchronous_dt{g in groupNonSync, (d, t) in dt} :=
  + step_duration[d, t]
      * vq_non_synchronous[g, d, t] 
	  * pdGroup[g, 'penalty_non_synchronous', d]
;

param r_costPenalty_reserve_upDown_dt{(r, ud, ng) in reserve__upDown__group, (d, t) in dt} :=
  + step_duration[d, t]
      * (
          + vq_reserve[r, ud, ng, d, t] * p_reserve_upDown_group[r, ud, ng, 'penalty_reserve']
	    )
;
		
param r_cost_entity_invest_d{(e, d) in ed_invest} :=
  + v_invest[e, d]
      * p_entity_unitsize[e]
      * ed_entity_annual[e, d]
;

param r_costOper_dt{(d, t) in dt} :=
  + sum{(c, n) in commodity_node} r_cost_commodity_dt[c, n, d, t]
  + sum{(g, c, n, d) in group_commodity_node_period_co2} r_cost_co2_dt[g, c, n, d, t]
  + sum{p in process} r_cost_process_variable_cost_dt[p, d, t]
#  + sum{(p, source, sink, m) in process__source__sink__ramp_method : m in ramp_cost_method}
#      + r_cost_process_ramp_cost_dt[p, d, t]
  + sum{p in process_online : pdProcess[p, 'startup_cost', d]} r_cost_startup_dt[p, d, t]
;

param r_costPenalty_dt{(d, t) in dt} :=
  + sum{n in nodeBalance, ud in upDown} r_costPenalty_nodeState_upDown_dt[n, ud, d, t]
  + sum{g in groupInertia} r_costPenalty_inertia_dt[g, d, t]
  + sum{g in groupNonSync} r_costPenalty_non_synchronous_dt[g, d, t]
  + sum{(r, ud, ng) in reserve__upDown__group} r_costPenalty_reserve_upDown_dt[r, ud, ng, d, t]
;

param r_costOper_and_penalty_dt{(d,t) in dt} :=
  + r_costOper_dt[d, t]
  + r_costPenalty_dt[d, t]
;

param r_cost_co2_d{d in period} := sum{(g, c, n, d) in group_commodity_node_period_co2, (d, t) in dt} r_cost_co2_dt[g, c, n, d, t];
param r_cost_commodity_d{d in period} := sum{(c, n) in commodity_node, (d, t) in dt} r_cost_commodity_dt[c, n, d, t];
param r_cost_variable_d{d in period} := sum{p in process, (d, t) in dt} r_cost_process_variable_cost_dt[p, d, t];
#param r_cost_ramp_d{d in period} := sum{(p, source, sink, m) in process__source__sink__ramp_method, (d, t) in dt : m in ramp_cost_method} r_cost_process_ramp_cost_dt[p, d, t];
param r_cost_startup_d{d in period} := sum{p in process_online, (d, t) in dt : pdProcess[p, 'startup_cost', d]} r_cost_startup_dt[p, d, t];

param r_costPenalty_nodeState_upDown_d{n in nodeBalance, ud in upDown, d in period} := sum{(d, t) in dt} r_costPenalty_nodeState_upDown_dt[n, ud, d, t];
param r_costPenalty_inertia_d{g in groupInertia, d in period} := sum{(d, t) in dt} r_costPenalty_inertia_dt[g, d, t];
param r_costPenalty_non_synchronous_d{g in groupNonSync, d in period} := sum{(d, t) in dt} r_costPenalty_non_synchronous_dt[g, d, t];
param r_costPenalty_reserve_upDown_d{(r, ud, ng) in reserve__upDown__group, d in period} := sum{(d, t) in dt} r_costPenalty_reserve_upDown_dt[r, ud, ng, d, t];

param r_costOper_d{d in period} := sum{(d, t) in dt} r_costOper_dt[d, t];
param r_costPenalty_d{d in period} := sum{(d, t) in dt} r_costPenalty_dt[d, t];
param r_costOper_and_penalty_d{d in period} := + r_costOper_d[d] + r_costPenalty_d[d];

param r_costInvestUnit_d{d in period} :=
  + sum{(e, d) in ed_invest : e in process_unit} r_cost_entity_invest_d[e, d]
;
param r_costInvestConnection_d{d in period} :=
  + sum{(e, d) in ed_invest : e in process_connection} r_cost_entity_invest_d[e, d]
;
param r_costInvestState_d{d in period} :=
  + sum{(e, d) in ed_invest : e in nodeState} r_cost_entity_invest_d[e, d]
;

param r_costInvest_d{d in period} := r_costInvestUnit_d[d] + r_costInvestConnection_d[d] + r_costInvestState_d[d];

param pdNodeInflow{n in node, d in period} := sum{(d, t) in dt} pdtNodeInflow[n, d, t];

param potentialVREgen{(p, n) in process_sink, d in period_realized : p in process_VRE} :=
  + sum{(p, source, n, f, m) in process__source__sink__profile__profile_method, (d, t) in dt : m = 'upper_limit'} 
      + pt_profile[f, t] * entity_all_capacity[p, d];

printf 'Transfer investments to the next solve...\n';
param fn_entity_invested symbolic := "solve_data/p_entity_invested.csv";
printf 'entity,p_entity_invested\n' > fn_entity_invested;
for {e in entity: e in entityInvest} 
  {
    printf '%s,%.8g\n', e, 
	  + (if not p_model['solveFirst'] then p_entity_invested[e] else 0)
	  + sum {d_invest in period_invest} v_invest[e, d_invest].val * p_entity_unitsize[e]
	>> fn_entity_invested;
  }

printf 'Write unit investment results...\n';
param fn_investment_unit symbolic := "output/investment_unit__period.csv";
for {i in 1..1 : p_model['solveFirst']}
  { printf 'unit,period,invested\n' > fn_investment_unit; }  # Clear the file on the first solve
for {(p, d) in pd_invest : d in period_realized && d in period_invest && p in process_unit}
  {
    printf '%s,%s,%.8g\n', p, d, v_invest[p, d].val * p_entity_unitsize[p] >> fn_investment_unit;
  }

printf 'Write connection investment results...\n';
param fn_investment_connection symbolic := "output/investment_connection__period.csv";
for {i in 1..1 : p_model['solveFirst']}
  { printf 'connection,period,invested\n' > fn_investment_connection; }  # Clear the file on the first solve
for {(p, d) in pd_invest : d in period_realized && d in period_invest && p in process_connection}
  {
    printf '%s,%s,%.8g\n', p, d, v_invest[p, d].val * p_entity_unitsize[p] >> fn_investment_connection;
  }

printf 'Write node/storage investment results...\n';
param fn_investment_node symbolic := "output/investment_node__period.csv";
for {i in 1..1 : p_model['solveFirst']}
  { printf 'node,period,invested\n' > fn_investment_node; }  # Clear the file on the first solve
for {(e, d) in ed_invest : d in period_realized && d in period_invest && e in nodeState}
  {
    printf '%s,%s,%.8g\n', e, d, v_invest[e, d].val * p_entity_unitsize[e] >> fn_investment_connection;
  }


printf 'Write summary results...\n';
param fn_summary symbolic := "output/summary_solve.csv";
for {i in 1..1 : p_model['solveFirst']}
  { printf '"Diagnostic results from all solves. Output at (UTC): %s"', time2str(gmtime(), "%FT%TZ") > fn_summary; }
for {s in solve_current} { printf '\n\n"Solve",%s\n', s >> fn_summary; }
printf '"Total cost obj. function (M CUR)",%.12g,"Minimized total system cost as ', (total_cost.val / 1000000) >> fn_summary;
printf 'given by the solver (includes all penalty costs)"\n' >> fn_summary;
printf '"Total cost calculated full horizon (M CUR)",%.12g,', sum{d in period} (r_costOper_and_penalty_d[d] / period_share_of_year[d] + r_costInvest_d[d]) / 1000000 >> fn_summary;
printf '"Annualized operational, penalty and investment costs"\n' >> fn_summary;
printf '"Total cost calculated realized periods (M CUR)",%.12g\n', sum{d in period_realized} (r_costOper_and_penalty_d[d] / period_share_of_year[d] + r_costInvest_d[d]) / 1000000 >> fn_summary;
printf '"Time in use in years",%.12g,"The amount of time the solve includes - calculated in years"', sum{d in period} period_share_of_year[d] >> fn_summary;
printf '\n' >> fn_summary;

printf '\nEmissions\n' >> fn_summary;
printf '"CO2 (Mt)",%.6g,"System-wide annualized CO2 emissions for all periods"\n', sum{c in commodity, d in period} (r_emissions_co2_commodity_d[c, d] / period_share_of_year[d]) / 1000000 >> fn_summary;
printf '"CO2 (Mt)",%.6g,"System-wide annualized CO2 emissions for realized periods"\n', sum{c in commodity, d in period_realized} (r_emissions_co2_commodity_d[c, d] / period_share_of_year[d]) / 1000000 >> fn_summary;

printf '\n"Possible issues (creating or removing energy/matter, creating inertia, ' >> fn_summary;
printf 'changing non-synchronous generation to synchronous)"\n' >> fn_summary;
for {n in nodeBalance}
  {  
    for {d in period : r_penalty_nodeState_upDown_d[n, 'up', d]}
      {
	    printf 'Created, %s, %s, %.5g\n', n, d, r_penalty_nodeState_upDown_d[n, 'up', d] >> fn_summary;
      }
  }

for {n in nodeBalance}
  {  
    for {d in period : r_penalty_nodeState_upDown_d[n, 'down', d]}
      {
	    printf 'Removed, %s, %s, %.5g\n', n, d, r_penalty_nodeState_upDown_d[n, 'down', d] >> fn_summary;
      }
  }

for {g in groupInertia}
  {
    for {d in period : r_costPenalty_inertia_d[g, d]}
	  {
        printf 'Inertia, %s, %s, %.5g\n', g, d, r_costPenalty_inertia_d[g, d] / pdGroup[g, 'penalty_inertia', d] >> fn_summary;
	  }
  }

for {g in groupNonSync}
  {
    for {d in period : r_costPenalty_non_synchronous_d[g, d]}
	  {
        printf 'NonSync, %s, %s, %.5g\n', g, d, r_costPenalty_non_synchronous_d[g, d] / pdGroup[g, 'penalty_non_synchronous', d] >> fn_summary;
	  }
  }

printf 'Write group results for nodes...\n';
param fn_groupNode__d symbolic := "output/group_node__period.csv";
for {i in 1..1 : p_model['solveFirst']}
  { 
    printf ',,"Sum of inflows","VRE share","Curtailed VRE share","Created energy or matter",' > fn_groupNode__d;
	printf '"Removed energy or matter"\nGroup,Period,"MWh","\% of annual inflow","\% of annual inflow",' >> fn_groupNode__d;
	printf '"\% of annual inflow","\% of annual inflow"\n' >> fn_groupNode__d;
  }
for {g in groupOutput, d in period_realized}
  {
    printf '%s,%s,%.8g,%.8g,%.8g,%.8g,%.8g\n', g, d 
       , sum{(g, n) in group_node} pdNodeInflow[n, d]
       , ( sum{(p, source, n) in process_source_sink_alwaysProcess : (g, n) in group_node && p in process_VRE && (p, n) in process_sink} 
	             r_process_source_sink_flow_d[p, source, n, d] ) 
		 / ( - sum{(g, n) in group_node} pdNodeInflow[n, d] ) * 100	   
	   , ( + sum{(p, n) in process_sink : p in process_VRE} potentialVREgen[p, n, d]
	       - sum{(p, source, n) in process_source_sink_alwaysProcess : (g, n) in group_node && p in process_VRE && (p, n) in process_sink} 
		         r_process_source_sink_flow_d[p, source, n, d]
		 ) / ( - sum{(g, n) in group_node} pdNodeInflow[n, d] ) * 100
	  , ( sum{(g, n) in group_node} r_penalty_nodeState_upDown_d[n, 'up', d] ) 
	    / ( - sum{(g, n) in group_node} pdNodeInflow[n, d] ) * 100
	  , ( sum{(g, n) in group_node} r_penalty_nodeState_upDown_d[n, 'down', d] ) 
	    / ( - sum{(g, n) in group_node} pdNodeInflow[n, d] ) * 100
	>> fn_groupNode__d;
  }


printf 'Write cost summary for realized periods...\n';
param fn_summary_cost symbolic := "output/costs__period.csv";
for {i in 1..1 : p_model['solveFirst']}
  { 
    printf ',,Investments,,,"Operational costs",,,,"Penalty costs",,,,,\nPeriod,' > fn_summary_cost;
    printf 'Total,Unit,Connection,Storage,Commodity,CO2,O&M,Starts,"Created matter or energy","Removed ' >> fn_summary_cost;
	printf '"matter or energy","Lack of inertia","Non-synchronous","Created reserves","Removed reserves"\n' >> fn_summary_cost;
  }
for {d in period_realized}
  { 
    printf '%s,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g\n', 
      d,
	  (r_costOper_and_penalty_d[d] / period_share_of_year[d] + r_costInvest_d[d]) / 1000000,
      r_costInvestUnit_d[d] / 1000000,
      r_costInvestConnection_d[d] / 1000000,
      r_costInvestState_d[d] / 1000000,
	  r_cost_commodity_d[d] / period_share_of_year[d] / 1000000,
	  r_cost_co2_d[d] / period_share_of_year[d] / 1000000,
	  r_cost_variable_d[d] / period_share_of_year[d] / 1000000,
	  r_cost_startup_d[d] / period_share_of_year[d] / 1000000,
	  sum{n in nodeBalance} (r_costPenalty_nodeState_upDown_d[n, 'up', d] / period_share_of_year[d]) / 1000000,
	  sum{n in nodeBalance} (r_costPenalty_nodeState_upDown_d[n, 'down', d] / period_share_of_year[d]) / 1000000,
	  sum{g in groupInertia} (r_costPenalty_inertia_d[g, d] / period_share_of_year[d]) / 1000000,
	  sum{g in groupNonSync} (r_costPenalty_non_synchronous_d[g, d] / period_share_of_year[d]) / 1000000,
	  sum{(r, ud, ng) in reserve__upDown__group : ud = 'up'} (r_costPenalty_reserve_upDown_d[r, ud, ng, d] / period_share_of_year[d]) / 1000000,
	  sum{(r, ud, ng) in reserve__upDown__group : ud = 'down'} (r_costPenalty_reserve_upDown_d[r, ud, ng, d] / period_share_of_year[d]) / 1000000
	>> fn_summary_cost;
  } 

printf 'Write unit__sinkNode flow for periods...\n';
param fn_unit__sinkNode__d symbolic := "output/unit__sinkNode__period.csv";
for {i in 1..1 : p_model['solveFirst']}
  { printf 'unit,node,period,flow\n' > fn_unit__sinkNode__d; }  # Print the header on the first solve
for {u in process_unit, d in period_realized}
  {
    for {(u, sink) in process_sink}
      {
        printf '%s,%s,%s,%.8g\n', u, sink, d, r_process_sink_flow_d[u, sink, d] >> fn_unit__sinkNode__d;
      }
  } 

printf 'Write unit__sinkNode flow for time...\n';
param fn_unit__sinkNode__dt symbolic := "output/unit__sinkNode__period__t.csv";
for {i in 1..1 : p_model['solveFirst']}
  { printf 'unit,node,period,time,flow\n' > fn_unit__sinkNode__dt; }  # Print the header on the first solve
for {(u, m) in process_method, (d, t) in dt : d in period_realized && u in process_unit}
  {
    for {(u, source, sink) in process_source_sink_alwaysProcess : (u, sink) in process_sink}
      {
        printf '%s,%s,%s,%s,%.8g\n', u, sink, d, t, r_process_source_sink_flow_dt[u, source, sink, d, t] >> fn_unit__sinkNode__dt;
      }
  } 

printf 'Write unit__sourceNode flow for periods...\n';
param fn_unit__sourceNode__d symbolic := "output/unit__sourceNode__period.csv";
for {i in 1..1 : p_model['solveFirst']}
  { printf 'unit,node,period,flow\n' > fn_unit__sourceNode__d; }  # Print the header on the first solve
for {u in process_unit, d in period_realized}
  {
    for {(u, source) in process_source}
      {
        printf '%s,%s,%s,%.8g\n', u, source, d, r_process_source_flow_d[u, source, d] >> fn_unit__sourceNode__d;
      }
  } 

printf 'Write unit__sourceNode flow for time...\n';
param fn_unit__sourceNode__dt symbolic := "output/unit__sourceNode__period__t.csv";
for {i in 1..1 : p_model['solveFirst']}
  { printf 'unit,node,period,time,flow\n' > fn_unit__sourceNode__dt; }  # Print the header on the first solve
for {(u, m) in process_method, (d, t) in dt : d in period_realized && u in process_unit}
  {
    for {(u, source, sink) in process_source_sink_alwaysProcess : (u, source) in process_source}
      {
        printf '%s,%s,%s,%s,%.8g\n', u, source, d, t, r_process_source_sink_flow_dt[u, source, sink, d, t] >> fn_unit__sourceNode__dt;
      }
  } 

printf 'Write connection flow for periods...\n';
param fn_connection__d symbolic := "output/connection__period.csv";
for {i in 1..1 : p_model['solveFirst']}
  { printf 'connection,source,sink,period,flow\n' > fn_connection__d; }  # Print the header on the first solve
for {(c, source, sink) in process_source_sink_alwaysProcess, d in period_realized : c in process_connection}
  {
    printf '%s,%s,%s,%s,%.8g\n', c, source, sink, d, r_process_source_sink_flow_d[c, source, sink, d] >> fn_connection__d;
  } 

printf 'Write connection flow for time...\n';
param fn_connection__dt symbolic := "output/connection__period__t.csv";
for {i in 1..1 : p_model['solveFirst']}
  { printf 'connection,source,sink,period,time,flow\n' > fn_connection__dt; }  # Print the header on the first solve
for {(c, source, sink) in process_source_sink_alwaysProcess, (d, t) in dt 
       : d in period_realized && c in process_connection }
  {
    printf '%s,%s,%s,%s,%s,%.8g\n', c, source, sink, d, t, r_process_source_sink_flow_dt[c, source, sink, d, t] >> fn_connection__dt;
  } 

printf 'Write reserve from processes over time...\n';
param fn_process__reserve__upDown__node__dt symbolic := "output/process__reserve__upDown__node__period__t.csv";
for {i in 1..1 : p_model['solveFirst']}
  { printf 'process,reserve,upDown,node,period,time,reservation\n' > fn_process__reserve__upDown__node__dt; }  # Print the header on the first solve
for {(p, r, ud, n) in process_reserve_upDown_node_active, (d, t) in dt}
  {
    printf '%s,%s,%s,%s,%s,%s,%.8g\n', p, r, ud, n, d, t, v_reserve[p, r, ud, n, d, t].val >> fn_process__reserve__upDown__node__dt;
  }

printf 'Write online status of units over time...\n';
param fn_unit_online__dt symbolic := "output/unit_online__period__t.csv";
for {i in 1..1 : p_model['solveFirst']}
  { printf 'period,time' > fn_unit_online__dt; 
    for {p in process_unit  : p in process_online}
      { printf ',%s', p >> fn_unit_online__dt; }
  }  # Print the header on the first solve
for {(d, t) in dt}
  {
    printf '\n%s,%s', d, t >> fn_unit_online__dt;
	for {p in process_unit : p in process_online}
	  {
	    printf ',%.8g', v_online_linear[p, d, t].val >> fn_unit_online__dt;
	  }
  }
 
printf 'Write node results for periods...\n';
param fn_node__d symbolic := "output/node__period.csv";
for {i in 1..1 : p_model['solveFirst']}
  { printf 'Node,Period,Inflow,"From units","From connections","To units","To connections",' > fn_node__d;
    printf '"State change","Self discharge","Create with penalty","Remove with penalty"\n' >> fn_node__d; }  # Print the header on the first solve
for {n in node, d in period_realized}
  {
    printf '%s,%s,%.8g,%.8g,%.8g,%.8g,%.8g,%.8g,%.8g,%.8g,%.8g\n'
		, n, d
        , (if (n, 'no_inflow') not in node__inflow_method then sum{(d, t) in dt : d in period_realized} pdtNodeInflow[n, d, t])
	    , sum{(p, source, n) in process_source_sink_alwaysProcess : p in process_unit} r_process_source_sink_flow_d[p, source, n, d]
	    , sum{(p, source, n) in process_source_sink_alwaysProcess : p in process_connection} r_process_source_sink_flow_d[p, source, n, d]
  	    , sum{(p, n, sink) in process_source_sink_alwaysProcess : p in process_unit} -r_process_source_sink_flow_d[p, n, sink, d]
  	    , sum{(p, n, sink) in process_source_sink_alwaysProcess : p in process_connection} -r_process_source_sink_flow_d[p, n, sink, d]
	    , (if n in nodeState then r_nodeState_change_d[n, d] else 0)
        , (if n in nodeSelfDischarge then r_selfDischargeLoss_d[n, d] else 0)
	    , sum{ud in upDown : ud = 'up' && n in nodeBalance} r_penalty_nodeState_upDown_d[n, ud, d]
	    , sum{ud in upDown : ud = 'down' && n in nodeBalance} -r_penalty_nodeState_upDown_d[n, ud, d]
	  >> fn_node__d;
  }

printf 'Write node results for time...\n';
param fn_node__dt symbolic := "output/node__period__t.csv";
for {i in 1..1 : p_model['solveFirst']}
  { printf 'Node,Period,Time,Inflow,"From units","From connections","To units","To connections",' > fn_node__dt;
    printf '"State","Self discharge","Create with penalty","Remove with penalty"\n' >> fn_node__dt; }  # Print the header on the first solve
for {n in node, (d, t) in dt : d in period_realized}
  {
    printf '%s,%s,%s,%.8g,%.8g,%.8g,%.8g,%.8g,%.8g,%.8g,%.8g,%.8g\n'
		, n, d, t
        , (if (n, 'no_inflow') not in node__inflow_method then pdtNodeInflow[n, d, t])
	    , sum{(p, source, n) in process_source_sink_alwaysProcess : p in process_unit} r_process_source_sink_flow_dt[p, source, n, d, t]
	    , sum{(p, source, n) in process_source_sink_alwaysProcess : p in process_connection} r_process_source_sink_flow_dt[p, source, n, d, t]
  	    , sum{(p, n, sink) in process_source_sink_alwaysProcess : p in process_unit} -r_process_source_sink_flow_dt[p, n, sink, d, t]
  	    , sum{(p, n, sink) in process_source_sink_alwaysProcess : p in process_connection} -r_process_source_sink_flow_dt[p, n, sink, d, t]
	    , (if n in nodeState then v_state[n, d, t].val else 0)
        , (if n in nodeSelfDischarge then r_selfDischargeLoss_dt[n, d, t] else 0)
	    , sum{ud in upDown : n in nodeBalance} vq_state_up[n, d, t].val
	    , sum{ud in upDown : n in nodeBalance} -vq_state_down[n, d, t].val
	  >> fn_node__dt;
  }

printf 'Write nodal prices for time...\n';
param fn_nodal_prices__dt symbolic := "output/node_prices__period__t.csv";
printf 'period,time' > fn_nodal_prices__dt;
for {n in nodeBalance}
  { printf ',%s', n >> fn_nodal_prices__dt; }
for {(d, t, t_previous, t_previous_within_block) in dttt : d in period_realized}
  {
    printf '\n%s,%s', d, t >> fn_nodal_prices__dt;
    for {n in nodeBalance}
	  {
	    printf ',%8g', nodeBalance_eq[n, d, t, t_previous, t_previous_within_block].dual * period_share_of_year[d] >> fn_nodal_prices__dt;
      }
  }

printf 'Write node state for time..\n';
param fn_nodeState__dt symbolic := "output/node_state__period__t.csv";
for {i in 1..1 : p_model['solveFirst']}
  { printf 'period,time' > fn_nodeState__dt;
    for {n in nodeState}
      { printf ',%s', n >> fn_nodeState__dt; }
  }
for {(d, t) in dt : d in period_realized && d not in period_invest}
  { printf '\n%s,%s', d, t >> fn_nodeState__dt;
    for {n in nodeState} 
      {
	    printf ',%.8g', v_state[n, d, t].val >> fn_nodeState__dt;
      }
  }
		


printf 'Write group inertia over time...\n';
param fn_group_inertia__dt symbolic := "output/group_inertia__period__t.csv";
for {i in 1..1 : p_model['solveFirst']}
  { printf 'group,period,time,inertia,penalty_variable\n' > fn_group_inertia__dt; }
for {g in groupInertia, (d, t) in dt : d in period_realized}
  {
    printf '%s,%s,%s,%.8g,%.8g\n'
	    , g, d, t
		, + sum {(p, source, sink) in process_source_sink : (p, source) in process_source && (g, source) in group_node && p_process_source[p, source, 'inertia_constant']} 
            ( + (if p in process_online then v_online_linear[p, d, t]) 
	          + (if p not in process_online then v_flow[p, source, sink, d, t])
	        ) * p_process_source[p, source, 'inertia_constant']
          + sum {(p, source, sink) in process_source_sink : (p, sink) in process_sink && (g, sink) in group_node && p_process_sink[p, sink, 'inertia_constant']} 
            ( + (if p in process_online then v_online_linear[p, d, t]) 
	          + (if p not in process_online then v_flow[p, source, sink, d, t])
            ) * p_process_sink[p, sink, 'inertia_constant']
		, vq_inertia[g, d, t]
		>> fn_group_inertia__dt;
  }


param resultFile symbolic := "output/result.csv";

printf 'Upward slack for node balance\n' > resultFile;
for {n in nodeBalance, (d, t) in dt}
  {
    printf '%s,%s,%s,%.8g\n', n, d, t, vq_state_up[n, d, t].val >> resultFile;
  }

printf '\nDownward slack for node balance\n' >> resultFile;
for {n in nodeBalance, (d, t) in dt}
  {
    printf '%s,%s,%s,%.8g\n', n, d, t, vq_state_down[n, d, t].val >> resultFile;
  }

printf '\nReserve upward slack variable\n' >> resultFile;
for {(r, ud, ng) in reserve__upDown__group, (d, t) in dt}
  {
    printf '%s,%s,%s,%s,%s,%.8g\n', r, ud, ng, d, t, vq_reserve[r, ud, ng, d, t].val >> resultFile;
  }

printf '\nFlow variables\n' >> resultFile;
for {(p, source, sink) in process_source_sink, (d, t) in dt}
  {
    printf '%s,%s,%s,%s,%s,%.8g\n', p, source, sink, d, t, v_flow[p, source, sink, d, t].val >> resultFile;
  }

printf '\nInvestments\n' >> resultFile;
for {(e, d_invest) in ed_invest} {
  printf '%s,%s,%.8g\n', e, d_invest, v_invest[e, d_invest].val * p_entity_unitsize[e] >> resultFile;
}

printf '\nDivestments\n' >> resultFile;
for {(e, d_invest) in ed_divest} {
  printf '%s,%s,%.8g\n', e, d_invest, v_divest[e, d_invest].val * p_entity_unitsize[e] >> resultFile;
}


printf '\nNode balances\n' >> resultFile;
for {n in node} {
  printf '\n%s\nPeriod, Time', n >> resultFile;
  printf (if (n, 'scale_to_annual_flow') in node__inflow_method then ', %s' else ''), n >> resultFile;
  for {(p, source, n) in process_source_sink} {
    printf ', %s->', source >> resultFile;
  }
  for {(p, n, sink) in process_source_sink : sum{(p, m) in process_method : m in method_1var_per_way} 1 } {
    printf ', ->%s', sink >> resultFile;
  }
  for {(p, n, sink) in process_source_sink : sum{(p, m) in process_method : m not in method_1var_per_way} 1 } {
    printf ', ->%s->', sink >> resultFile;
  }
  printf '\n' >> resultFile;
  for {(d, t) in dt} {
    printf '%s,%s', d, t >> resultFile;
	printf (if (n, 'scale_to_annual_flow') in node__inflow_method then ', %.8g' else ''), ptNode[n, 'inflow', t] >> resultFile; 
    for {(p, source, n) in process_source_sink_alwaysProcess} {
      printf ',%.8g', + r_process_source_sink_flow_dt[p, source, n, d, t] >> resultFile;
	}
    for {(p, n, sink) in process_source_sink_alwaysProcess} {
      printf ',%.8g', - r_process_source_sink_flow_dt[p, n, sink, d, t]
        >> resultFile;
	}
    printf '\n' >> resultFile;
  }
}


### UNIT TESTS ###
param unitTestFile symbolic := "tests/unitTests.txt";
printf (if sum{d in debug} 1 then '%s --- ' else ''), time2str(gmtime(), "%FT%TZ") > unitTestFile;
for {d in debug} {
  printf '%s  ', d >> unitTestFile;
}
printf (if sum{d in debug} 1 then '\n\n' else '') >> unitTestFile;

## Objective test
printf (if (sum{d in debug} 1 && total_cost.val <> d_obj) 
        then 'Objective value test fails. Model value: %.8g, test value: %.8g\n' else ''), total_cost.val, d_obj >> unitTestFile;

## Testing flows from and to node
for {n in node : 'method_1way_1var' in debug || 'mini_system' in debug} {
  printf 'Testing incoming flows of node %s\n', n >> unitTestFile;
  for {(p, source, n, d, t) in peedt} {
    printf (if v_flow[p, source, n, d, t].val <> d_flow[p, source, n, d, t] 
	        then 'Test fails at %s, %s, %s, %s, %s, model value: %.8g, test value: %.8g\n' else ''),
			    p, source, n, d, t, v_flow[p, source, n, d, t].val, d_flow[p, source, n, d, t] >> unitTestFile;
  }
  printf 'Testing outgoing flows of node %s\n', n >> unitTestFile;
  for {(p, n, sink, d, t) in peedt : sum{(p, m) in process_method : m = 'method_1var' || m = 'method_2way_2var'} 1 } {
    printf (if -v_flow[p, n, sink, d, t].val / ptProcess[p, 'efficiency', t] <> d_flow_1_or_2_variable[p, n, sink, d, t]
	        then 'Test fails at %s, %s, %s, %s, %s, model value: %.8g, test value: %.8g\n' else ''),
	            p, n, sink, d, t, -v_flow[p, n, sink, d, t].val / ptProcess[p, 'efficiency', t], d_flow_1_or_2_variable[p, n, sink, d, t] >> unitTestFile;
  }
  for {(p, n, sink, d, t) in peedt : sum{(p, m) in process_method : m in method && (m <> 'method_1var' || m <> 'method_2way_2var')} 1 } {
    printf (if -v_flow[p, n, sink, d, t].val <> d_flow[p, n, sink, d, t] 
	        then 'Test fails at %s, %s, %s, %s, %s, model value: %.8g, test value: %.8g\n' else ''),
	            p, n, sink, d, t, -v_flow[p, n, sink, d, t].val, d_flow[p, n, sink, d, t] >> unitTestFile;
  }
  printf '\n' >> unitTestFile;
}  

## Testing reserves
for {(p, r, ud, n, d, t) in prundt} {
  printf (if v_reserve[p, r, ud, n, d, t].val <> d_reserve_upDown_node[p, r, ud, n, d, t]
          then 'Reserve test fails at %s, %s, %s, %s, %s, %s. Model value: %.8g, test value: %.8g\n' else ''),
		      p, r, ud, n, d, t, v_reserve[p, r, ud, n, d, t].val, d_reserve_upDown_node[p, r, ud, n, d, t] >> unitTestFile;
}
for {(r, ud, ng) in reserve__upDown__group, (d, t) in dt} {
  printf (if vq_reserve[r, ud, ng, d, t].val <> dq_reserve[r, ud, ng, d, t]
          then 'Reserve slack variable test fails at %s, %s, %s, %s, %s. Model value: %.8g, test value: %.8g\n' else ''),
		      r, ud, ng, d, t, vq_reserve[r, ud, ng, d, t].val, dq_reserve[r, ud, ng, d, t] >> unitTestFile;
}

## Testing investments
#for {(p, n, d_invest) in ped_invest : 'invest_source_to_sink' in debug} {
#  printf 'Testing investment decisions of %s %s %s\n', p, n, d_invest >> unitTestFile;
#  printf (if v_flowInvest[p, n, d_invest].val <> d_flowInvest[p, n, d_invest]
#          then 'Test fails at %s, %s, %s, model value: %.8g, test value: %.8g\n' else ''),
#		      p, n, d_invest, v_flowInvest[p, n, d_invest].val, d_flowInvest[p, n, d_invest] >> unitTestFile;
#}
printf (if sum{d in debug} 1 then '\n\n' else '') >> unitTestFile;	  

display {(p, source, sink) in process_source_sink_alwaysProcess, (d, t) in test_dt}: r_process_source_sink_flow_dt[p, source, sink, d, t];
display {(p, source, sink, d, t) in peedt : (d, t) in test_dt}: v_flow[p, source, sink, d, t].val;
#display {(p, r, ud, n, d, t) in prundt : (d, t) in test_dt}: v_reserve[p, r, ud, n, d, t].val;
#display {(r, ud, ng) in reserve__upDown__group, (d, t) in test_dt}: vq_reserve[r, ud, ng, d, t].val;
#display {n in nodeBalance, (d, t) in test_dt}: vq_state_up[n, d, t].val;
#display {n in nodeBalance, (d, t) in test_dt}: vq_state_down[n, d, t].val;
#display {g in groupInertia, (d, t) in test_dt}: inertia_constraint[g, d, t].dual;
#display {n in nodeBalance, (d, t, t_previous, t_previous_within_block) in dttt : (d, t) in test_dt}: nodeBalance_eq[n, d, t, t_previous, t_previous_within_block].dual;
#display r_costOper_and_penalty_d;
display v_invest;
end;
