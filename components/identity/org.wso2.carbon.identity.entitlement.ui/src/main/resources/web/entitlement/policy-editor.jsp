<!--
/*
* Copyright (c) 2008, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/
-->

<%@ page import="org.wso2.carbon.identity.entitlement.ui.EntitlementPolicyConstants" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.Arrays" %>
<%@ page import="org.wso2.carbon.identity.entitlement.ui.dto.*" %>
<%@ page import="org.wso2.carbon.identity.entitlement.ui.PolicyEditorConstants" %>
<%@ page import="java.util.List" %>
<%@ page import="org.wso2.carbon.ui.util.CharacterEncoder" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://wso2.org/projects/carbon/taglibs/carbontags.jar" prefix="carbon" %>
<jsp:useBean id="entitlementPolicyBean"
             type="org.wso2.carbon.identity.entitlement.ui.EntitlementPolicyBean"
             class="org.wso2.carbon.identity.entitlement.ui.EntitlementPolicyBean" scope="session"/>
<jsp:setProperty name="entitlementPolicyBean" property="*"/>


<%
    String ruleId = null;
    RuleDTO ruleDTO = null;
    String currentCategory = null;
    String currentPreFunction = null;
    String currentFunction = null;
    String currentAttributeValue =  null;
    String currentAttributeId =  null;
    String currentAttributeDataType = null;
    String currentCombineFunction = null;

    String currentRuleCategory = null;
    String currentRulePreFunction = null;
    String currentRuleFunction = null;
    String currentRuleAttributeValue =  null;
    String currentRuleAttributeId =  null;
    String currentRuleAttributeDataType = null;
    String currentRuleCombineFunction = null;

    String currentRuleTargetCategory = null;
    String currentRuleTargetPreFunction = null;
    String currentRuleTargetFunction = null;
    String currentRuleTargetAttributeValue =  null;
    String currentRuleTargetAttributeId =  null;
    String currentRuleTargetAttributeDataType = null;
    String currentRuleTargetCombineFunction = null;

    String currentDynamicId = null;
    String currentDynamicSelector = null;
    String currentDynamicCategory = null;
    String currentDynamicFunction = null;
    String currentDynamicAttributeValue= null;
    String currentDynamicAttributeId= null;
    String currentDynamicAttributeDataType= null;

    String currentObligationId = null;
    String currentObligationEffect = null;
    String currentObligationType = null;
    String currentObligationAttributeValue = null;
    String currentObligationAttributeId = null;

    String currentRuleObligationId = null;
    String currentRuleObligationType = null;
    String currentRuleObligationAttributeValue = null;
    String currentRuleObligationAttributeId = null;

    String selectedAttributeNames = "";
    String ruleEffect = "";

    String[] ruleEffects = new String[]{PolicyEditorConstants.RULE_EFFECT_PERMIT,
            PolicyEditorConstants.RULE_EFFECT_DENY};

    String[] combineFunctions = new String[] {PolicyEditorConstants.COMBINE_FUNCTION_END,
            PolicyEditorConstants.COMBINE_FUNCTION_AND, PolicyEditorConstants.COMBINE_FUNCTION_OR};

    String[] ruleCombingAlgorithm = new String[]{PolicyEditorConstants.CombiningAlog.RULE_COMBINING_DENY_OVERRIDE,
                            PolicyEditorConstants.CombiningAlog.RULE_COMBINING_PERMIT_OVERRIDE, 
                            PolicyEditorConstants.CombiningAlog.RULE_COMBINING_FIRST_APPLICABLE,
                            PolicyEditorConstants.CombiningAlog.RULE_COMBINING_PERMIT_UNLESS_DENY,
                            PolicyEditorConstants.CombiningAlog.RULE_COMBINING_DENY_UNLESS_PERMIT,
                            PolicyEditorConstants.CombiningAlog.RULE_COMBINING_ORDER_PERMIT_OVERRIDE,
                            PolicyEditorConstants.CombiningAlog.RULE_COMBINING_ORDER_DENY_OVERRIDE };

    String[] obligationTypes = new String[]{"Obligation", "Advice"};

    String[] dynamicSelectors = new String[]{PolicyEditorConstants.DYNAMIC_SELECTOR_CATEGORY,
                                   PolicyEditorConstants.DYNAMIC_SELECTOR_FUNCTION };

    String selectedAttributeDataType = request.getParameter("selectedAttributeDataType");
    String selectedAttributeId = request.getParameter("selectedAttributeId");

    // These are pass as hidden values. So can contain null value ...
    if ("null".equals(selectedAttributeId)) {
        selectedAttributeId = null;
    }

    if ("null".equals(selectedAttributeDataType)) {
        selectedAttributeDataType = null;
    }

     //Get posted resources from jsp pages and put then in to a String object
    int noOfSelectedAttributes = 1;
    while (true) {
        String attributeName = request.getParameter("resourceName" + noOfSelectedAttributes);
        if (attributeName == null || attributeName.trim().length() < 1) {
            break;
        }
        if (selectedAttributeNames.equals("")) {
            selectedAttributeNames = attributeName.trim();
        } else {
            selectedAttributeNames = selectedAttributeNames + "," + attributeName.trim();
        }
        noOfSelectedAttributes++;
    }

    ruleId = CharacterEncoder.getSafeText(request.getParameter("ruleId"));
    if (ruleId != null && ruleId.trim().length() > 0 && !ruleId.trim().equals("null")) {
        ruleDTO = entitlementPolicyBean.getRuleDTO(ruleId);
    }
    
    Set<String> categories = entitlementPolicyBean.getCategorySet();
    Set<String> rulePreFunctions = entitlementPolicyBean.getPreFunctions();
    rulePreFunctions.add("is");      // TODO
    String[] targetPreFunctions = new String[]{"is"};
    Set<String>  targetFunctions = entitlementPolicyBean.getTargetFunctionMap().keySet();
    Set<String>  ruleFunctions = entitlementPolicyBean.getRuleFunctionMap().keySet();

    List<RuleDTO> ruleDTOs = entitlementPolicyBean.getRuleDTOs();
    BasicTargetDTO targetDTO = entitlementPolicyBean.getTargetDTO();
    List<ObligationDTO> obligationDTOs = entitlementPolicyBean.getObligationDTOs();
    List<ExtendAttributeDTO>  extendAttributeDTOs = entitlementPolicyBean.getExtendAttributeDTOs();
%>

<script type="text/javascript">
    var selectorList = new Array();
</script>

<%
    for(String selector : dynamicSelectors){
        String tmp = "";
        if(PolicyEditorConstants.DYNAMIC_SELECTOR_FUNCTION.equals(selector)){
            for(String function : ruleFunctions){
                tmp += "<option value=\"" + function + "\" >" + function + "</option>";
            }
        } else {
            for(String category : categories){
                tmp += "<option value=\"" + category + "\" >" + category + "</option>";
            }
        }
%>

<script type="text/javascript">
    selectorList.push({key:'<%=selector%>',list:'<%=tmp%>'});
</script>

    <%
        }
    %>

<script type="text/javascript">

    function selectRightList(selector, index){
        var rightList = "";
        for(var i=0;i<selectorList.length;i++){
            if(selectorList[i].key == selector){
                rightList = selectorList[i].list;
            }
        }

        var selectorElement = document.getElementById('dynamicCategory_' + index);
        selectorElement.innerHTML = rightList;
    }
    
    function removeRow(link){
        link.parentNode.parentNode.parentNode.removeChild(link.parentNode.parentNode);

        jQuery(jQuery('.newTargetRow')[parseInt(jQuery('.newTargetRow').length, 10) - 1 ]).removeAttr('disabled');
        jQuery(jQuery('.newTargetRow')[parseInt(jQuery('.newTargetRow').length, 10) - 1 ]).val('END');

        jQuery(jQuery('.newRuleTargetRow')[parseInt(jQuery('.newRuleTargetRow').length, 10) - 1 ]).removeAttr('disabled');
        jQuery(jQuery('.newRuleTargetRow')[parseInt(jQuery('.newRuleTargetRow').length, 10) - 1 ]).val('END');

        jQuery(jQuery('.newRuleRow')[parseInt(jQuery('.newRuleRow').length, 10) - 1 ]).removeAttr('disabled');
        jQuery(jQuery('.newRuleRow')[parseInt(jQuery('.newRuleRow').length, 10) - 1 ]).val('END');
  
    }

    function createNewTargetRow(value) {
        if (value == "AND" || value == "OR"){
            jQuery('.newTargetRow').attr('disabled','disabled');
            var rowIndex =  jQuery('#multipleTargetTable tr').last().attr('data-value');
            var index = parseInt(rowIndex, 10) + 1;
            jQuery('#multipleTargetTable > tbody:last').append('<tr data-value="'+ index +'"><td style="padding-left:0px !important;padding-right:0px !important"><select id="targetCategory_'  + index + '" name="targetCategory_'  + index + '" > <%for (String category : categories) { if(currentCategory != null && category.equals(currentCategory)){%> <option value="<%=category%>" selected="selected"><%=currentCategory%> </option> <%} else {%> <option value="<%=category%>"><%=category%> </option> <%} }%></select></td>' +
                '<td style="padding-left:0px !important;padding-right:0px !important"><select id="targetPreFunction_'  + index + '" name="targetPreFunction_'  + index + '"><%for (String targetPreFunction : targetPreFunctions) {if (currentPreFunction != null && targetPreFunction.equals(currentPreFunction)) {%><option value="<%=targetPreFunction%>" selected="selected"><%=targetPreFunction%></option><%} else {%><option value="<%=targetPreFunction%>"><%=targetPreFunction%></option><%}}%></select></td>' +
                '<td style="padding-left:0px !important;padding-right:0px !important"><select id="targetFunction_'  + index + '" name="targetFunction_'  + index + '" class="leftCol-small"><%for (String targetFunction : targetFunctions) {if (currentFunction != null && targetFunction.equals(currentFunction)) {%><option value="<%=targetFunction%>" selected="selected"><%=targetFunction%></option><%} else {%><option value="<%=targetFunction%>"><%=targetFunction%></option><%}}%></select></td>' +
                '<td style="padding-left:0px !important;padding-right:0px !important"><%if (currentAttributeValue != null && !"".equals(currentAttributeValue)) {%><input type="text" size="60" name="targetAttributeValue_'  + index + '" id="targetAttributeValue_'  + index + '" value="<%=currentAttributeValue%>" class="text-box-big"/><%} else {%><input type="text" size="60" name="targetAttributeValue_'  + index + '" id="targetAttributeValue_'  + index + '" class="text-box-big"/><%}%></td>' +
                '<td><a title="Select Resources Names" class="icon-link" onclick="selectAttributesForTarget(' + index + ');" style="background-image:url(images/registry.gif);"></a></td>' +
                '<td style="padding-left:0px !important;padding-right:0px !important"><select id="targetCombineFunctions_'  + index + '" name="targetCombineFunctions_'  + index + '" class="newTargetRow" onchange="createNewTargetRow(this.options[this.selectedIndex].value)"><%for (String combineFunction : combineFunctions) {if (currentCombineFunction != null && combineFunction.equals(currentCombineFunction)) {%><option value="<%=combineFunction%>" selected="selected"><%=combineFunction%></option><%} else {%><option value="<%=combineFunction%>"><%=combineFunction%></option><%}}%></select></td>' +
                '<td><a onclick="removeRow(this)" style="background-image:url(images/delete.gif);" type="button" class="icon-link"></a></td>' +
                '<td><input type="hidden" name="targetAttributeId_'  + index +  '" id="targetAttributeId_'  + index + '" value="<%=currentAttributeId%>"/></td>' +
                '<td><input type="hidden" name="targetAttributeTypes_'  + index + '" id="targetAttributeTypes_'  + index +  '" value="<%=currentAttributeDataType%>"/></td>' +
                '</tr>');
        }
    }

    function createNewRuleTargetRow(value) {
        if (value == "AND" || value == "OR"){
            jQuery('.newRuleTargetRow').attr('disabled','disabled');
            var rowIndex =  jQuery('#multipleRuleTargetTable tr').last().attr('data-value');
            var index = parseInt(rowIndex, 10) + 1;
            jQuery('#multipleRuleTargetTable > tbody:last').append('<tr data-value="'+ index +'"><td style="padding-left:0px !important;padding-right:0px !important"><select id="ruleTargetCategory_'  + index + '" name="ruleTargetCategory_'  + index + '" > <%for (String category : categories) { if(currentRuleTargetCategory != null && category.equals(currentRuleTargetCategory)){%> <option value="<%=category%>" selected="selected"><%=currentCategory%> </option> <%} else {%> <option value="<%=category%>"><%=category%> </option> <%} }%></select></td>' +
                '<td style="padding-left:0px !important;padding-right:0px !important"><select id="ruleTargetPreFunction_'  + index + '" name="ruleTargetPreFunction_'  + index + '" ><%for (String targetPreFunction : targetPreFunctions) {if (currentRuleTargetPreFunction != null && targetPreFunction.equals(currentRuleTargetPreFunction)) {%><option value="<%=targetPreFunction%>" selected="selected"><%=targetPreFunction%></option><%} else {%><option value="<%=targetPreFunction%>"><%=targetPreFunction%></option><%}}%></select></td>' +
                '<td style="padding-left:0px !important;padding-right:0px !important"><select id="ruleTargetFunction_'  + index + '" name="ruleTargetFunction_'  + index + '" class="leftCol-small"><%for (String targetFunction : targetFunctions) {if (currentRuleTargetFunction != null && targetFunction.equals(currentRuleTargetFunction)) {%><option value="<%=targetFunction%>" selected="selected"><%=targetFunction%></option><%} else {%><option value="<%=targetFunction%>"><%=targetFunction%></option><%}}%></select></td>' +
                '<td style="padding-left:0px !important;padding-right:0px !important"><%if (currentRuleTargetAttributeValue != null && !"".equals(currentRuleTargetAttributeValue)) {%><input type="text" size="60" name="ruleTargetAttributeValue_'  + index + '" id="ruleTargetAttributeValue_'  + index + '" value="<%=currentAttributeValue%>" class="text-box-big"/><%} else {%><input type="text" size="60" name="ruleTargetAttributeValue_'  + index + '" id="ruleTargetAttributeValue_'  + index + '" class="text-box-big"/><%}%></td>' +
                '<td><a title="Select Resources Names" class="icon-link" onclick="selectAttributesForRuleTarget(' + index + ');" style="background-image:url(images/registry.gif);"></a></td>' +
                '<td style="padding-left:0px !important;padding-right:0px !important"><select id="ruleTargetCombineFunctions_'  + index + '" name="ruleTargetCombineFunctions_'  + index + '" class="newRuleTargetRow" onchange="createNewRuleTargetRow(this.options[this.selectedIndex].value)"><%for (String combineFunction : combineFunctions) {if (currentRuleTargetCombineFunction != null && combineFunction.equals(currentRuleTargetCombineFunction)) {%><option value="<%=combineFunction%>" selected="selected"><%=combineFunction%></option><%} else {%><option value="<%=combineFunction%>"><%=combineFunction%></option><%}}%></select></td>' +
                '<td><a onclick="removeRow(this)" style="background-image:url(images/delete.gif);" type="button" class="icon-link"></a></td>' +
                '<td><input type="hidden" name="ruleTargetAttributeId_'  + index +  '" id="ruleTargetAttributeId_'  + index + '" value="<%=currentRuleTargetAttributeId%>"/></td>' +
                '<td><input type="hidden" name="ruleTargetAttributeTypes_'  + index + '" id="ruleTargetAttributeTypes_'  + index +  '" value="<%=currentRuleTargetAttributeDataType%>"/></td>' +
                '</tr>');
        }
    }

    function createNewRuleRow(value) {
        if (value == "AND" || value == "OR"){
            jQuery('.newRuleRow').attr('disabled','disabled');
            var rowIndex =  jQuery('#multipleRuleTable tr').last().attr('data-value');
            var index = parseInt(rowIndex, 10) + 1;
            jQuery('#multipleRuleTable > tbody:last').append('<tr data-value="'+ index +'"><td style="padding-left:0px !important;padding-right:0px !important"><select id="ruleCategory_'  + index + '" name="ruleCategory_'  + index + '" > <%for (String category : categories) { if(currentRuleCategory != null && category.equals(currentRuleCategory)){%> <option value="<%=category%>" selected="selected"><%=category%> </option> <%} else {%> <option value="<%=category%>"><%=category%> </option> <%} }%></select></td>' +
                '<td style="padding-left:0px !important;padding-right:0px !important"><select id="rulePreFunction_'  + index + '" name="rulePreFunction_'  + index + '" ><%for (String rulePreFunction : rulePreFunctions) {if (currentRulePreFunction != null && rulePreFunction.equals(currentPreFunction)) {%><option value="<%=rulePreFunction%>" selected="selected"><%=rulePreFunction%></option><%} else {%><option value="<%=rulePreFunction%>"><%=rulePreFunction%></option><%}}%></select></td>' +
                '<td style="padding-left:0px !important;padding-right:0px !important"><select id="ruleFunction_'  + index + '" name="ruleFunction_'  + index + '" class="leftCol-small"><%for (String ruleFunction : ruleFunctions) {if (currentRuleFunction != null && ruleFunction.equals(currentRuleFunction)) {%><option value="<%=ruleFunction%>" selected="selected"><%=ruleFunction%></option><%} else {%><option value="<%=ruleFunction%>"><%=ruleFunction%></option><%}}%></select></td>' +
                '<td style="padding-left:0px !important;padding-right:0px !important"><%if (currentRuleAttributeValue != null && !"".equals(currentRuleAttributeValue)) {%><input type="text" size="60" name="ruleAttributeValue_'  + index + '" id="ruleAttributeValue_'  + index + '" value="<%=currentRuleAttributeValue%>" class="text-box-big"/><%} else {%><input type="text" size="60" name="ruleAttributeValue_'  + index + '" id="ruleAttributeValue_'  + index + '" class="text-box-big"/><%}%></td>' +
                '<td><a title="Select Resources Names" class="icon-link" onclick="selectAttributesForRule(' + index + ');" style="background-image:url(images/registry.gif);"></a></td>' +
                '<td style="padding-left:0px !important;padding-right:0px !important"><select id="ruleCombineFunctions_'  + index + '" name="ruleCombineFunctions_'  + index + '" class="newRuleRow" onchange="createNewRuleRow(this.options[this.selectedIndex].value)"><%for (String combineFunction : combineFunctions) {if (currentCombineFunction != null && combineFunction.equals(currentRuleCombineFunction)) {%><option value="<%=combineFunction%>" selected="selected"><%=combineFunction%></option><%} else {%><option value="<%=combineFunction%>"><%=combineFunction%></option><%}}%></select></td>' +
                '<td><a onclick="removeRow(this)" style="background-image:url(images/delete.gif);" type="button" class="icon-link"></a></td>' +
                '<td><input type="hidden" name="ruleAttributeId_'  + index +  '" id="ruleAttributeId_'  + index + '" value="<%=currentRuleAttributeId%>"/></td>' +
                '<td><input type="hidden" name="ruleAttributeTypes_'  + index + '" id="ruleAttributeTypes_'  + index +  '" value="<%=currentRuleAttributeDataType%>"/></td>' +
                '</tr>');
        }
    }

    function createNewRuleObligationRow() {
        var rowIndex =  jQuery('#obligationRuleTable tr').last().attr('data-value');
        var index = parseInt(rowIndex, 10) + 1;
        jQuery('#obligationRuleTable > tbody:last').append('<tr data-value="'+ index +'">' +
            '<td style="padding-left:0px !important;padding-right:0px !important"><select id="obligationRuleType_' + index +'" name="obligationRuleType_' + index +'" ><%for (String type : obligationTypes) {if (currentRuleObligationType != null && type.equals(currentRuleObligationType)) {%><option value="<%=type%>" selected="selected"><%=type%></option><%} else {%><option value="<%=type%>"><%=type%></option><%}}%></select></td>' +
            '<td style="padding-left:0px !important;padding-right:0px !important"><%if (currentRuleObligationId != null && currentRuleObligationId.trim().length() > 0) {%><input type="text" size="20" name="obligationRuleId_' + index +'" id="obligationRuleId_' + index +'" value="<%=currentRuleObligationId%>" /><%} else {%><input type="text" size="20" name="obligationRuleId_' + index +'" id="obligationRuleId_' + index +'" /><%}%></td>'+
            '<td style="padding-left:0px !important;padding-right:0px !important"><%if (currentRuleObligationAttributeValue != null && currentRuleObligationAttributeValue.trim().length() > 0) {%><input type="text" size="40" name="obligationRuleAttributeValue_' + index +'" id="obligationRuleAttributeValue_' + index +'" value="<%=currentRuleObligationAttributeValue%>" /> <%} else {%><input type="text" size="40" name="obligationRuleAttributeValue_' + index +'" id="obligationRuleAttributeValue_' + index +'"/><%}%></td>'+
            '<td style="padding-left:0px !important;padding-right:0px !important"><%if (currentRuleObligationAttributeId != null && currentRuleObligationAttributeId.trim().length() > 0) {%><input type="text" size="40" name="obligationRuleAttributeId_' + index +'" id="obligationRuleAttributeId_' + index +'" value="<%=currentRuleObligationAttributeId%>" /><%} else {%><input type="text" size="40" name="obligationRuleAttributeId_' + index +'" id="obligationRuleAttributeId_' + index +'"/><%}%></td>' +
            '<td><a onclick="removeRow(this)" style="background-image:url(images/delete.gif);" type="button" class="icon-link"></a></td>' +
            '</tr>');
    }

    function createNewObligationRow() {
        var rowIndex =  jQuery('#obligationTable tr').last().attr('data-value');
        var index = parseInt(rowIndex, 10) + 1;
        jQuery('#obligationTable > tbody:last').append('<tr data-value="'+ index +'">' +
            '<td style="padding-left:0px !important;padding-right:0px !important"><select id="obligationType_' + index +'" name="obligationType_' + index +'"><%for (String type : obligationTypes) {if (currentObligationType != null && type.equals(currentObligationType)) {%><option value="<%=type%>" selected="selected"><%=type%></option><%} else {%><option value="<%=type%>"><%=type%></option><%}}%></select></td>' +
            '<td style="padding-left:0px !important;padding-right:0px !important"><%if (currentObligationId != null && currentObligationId.trim().length() > 0) {%><input type="text" size="20" name="obligationId_' + index +'" id="obligationId_' + index +'" value="<%=currentObligationId%>" /><%} else {%><input type="text" size="20" name="obligationId_' + index +'" id="obligationId_' + index +'" /><%}%></td>'+
            '<td style="padding-left:0px !important;padding-right:0px !important"><select id="obligationEffect_' + index +'" name="obligationEffect_' + index +'"><%if (ruleEffects != null) {for (String effect : ruleEffects) {if (effect.equals(currentObligationEffect)) {%><option value="<%=effect%>" selected="selected"><%=ruleEffect%></option><%} else {%><option value="<%=effect%>"><%=effect%></option><%}}}%></select></td>' +
            '<td style="padding-left:0px !important;padding-right:0px !important"><%if (currentObligationAttributeValue != null && currentObligationAttributeValue.trim().length() > 0) {%><input type="text" size="40" name="obligationAttributeValue_" '+ index +' id="obligationAttributeValue_" '+ index +' value="<%=currentObligationAttributeValue%>" /> <%} else {%><input type="text" size="40" name="obligationAttributeValue_' + index +'" id="obligationAttributeValue_' + index +'" /><%}%></td>'+
            '<td style="padding-left:0px !important;padding-right:0px !important"><%if (currentObligationAttributeId != null && currentObligationAttributeId.trim().length() > 0) {%><input type="text" size="40" name="obligationAttributeId_' + index +'" id="obligationAttributeId_' + index +'" value="<%=currentObligationAttributeId%>" /><%} else {%><input type="text" size="40" name="obligationAttributeId_' + index +'" id="obligationAttributeId_' + index +'"/><%}%></td>' +
            '<td><a onclick="removeRow(this)" style="background-image:url(images/delete.gif);" type="button" class="icon-link"></a></td>' +
            '</tr>');
    }

    function createNewExtendAttributeValueRow() {
        var  index = jQuery('#extendAttributeTable tr').length;
        jQuery('#extendAttributeTable > tbody:last').append('<tr>' + 
            '<td style="padding-left:0px !important;padding-right:0px !important"><%if (currentDynamicId != null && currentDynamicId.trim().length() > 0) {%><input  name="dynamicId_0"  id="dynamicId_0" value="<%=currentDynamicId%>" /><%} else {%><input  name="dynamicId_0" id="dynamicId_0" /><%}%></td>' +
            '<td style="padding-left:0px !important;padding-right:0px !important"><select id="dynamicSelector_0" name="dynamicSelector_0" class="leftCol-small"><%for (String selector : dynamicSelectors) { if (currentDynamicSelector != null && selector.equals(currentDynamicSelector)) {%><option value="<%=selector%>" selected="selected"><%=selector%></option><%} else {%><option value="<%=selector%>"><%=selector%></option><%}}%></select></td>' +
            '</tr>');
    }

</script>
                                         
<%
    if(targetDTO != null){
        List<RowDTO> rowDTOs = targetDTO.getRowDTOList();
        if(rowDTOs != null  && rowDTOs.size() > 0){
            RowDTO rowDTO = rowDTOs.get(0);
            currentCategory = rowDTO.getCategory();
            currentPreFunction = rowDTO.getPreFunction();
            currentFunction = rowDTO.getFunction();
            if(rowDTO.isNotCompleted()){
                if(rowDTO.getAttributeValue() != null && rowDTO.getAttributeValue().trim().length() > 0){
                    currentAttributeValue = rowDTO.getAttributeValue() + "," + selectedAttributeNames;
                } else {
                    currentAttributeValue = selectedAttributeNames;                    
                }
                currentAttributeId = selectedAttributeId;
                currentAttributeDataType = selectedAttributeDataType;
            } else {
                currentAttributeValue =  rowDTO.getAttributeValue();
                currentAttributeId =  rowDTO.getAttributeId();
                currentAttributeDataType = rowDTO.getAttributeDataType();
            }
            currentCombineFunction =  rowDTO.getCombineFunction();
        }
    }

    if(ruleDTO != null){
        ruleId = ruleDTO.getRuleId();
        ruleEffect = ruleDTO.getRuleEffect();
        List<RowDTO> rowDTOs = ruleDTO.getRowDTOList();
        if(rowDTOs != null  && rowDTOs.size() > 0){
            RowDTO rowDTO = rowDTOs.get(0);
            currentRuleCategory = rowDTO.getCategory();
            currentRulePreFunction = rowDTO.getPreFunction();
            currentRuleFunction = rowDTO.getFunction();
            if(rowDTO.isNotCompleted()){
                if(rowDTO.getAttributeValue() != null && rowDTO.getAttributeValue().trim().length() > 0){
                    currentRuleAttributeValue = rowDTO.getAttributeValue() + "," + selectedAttributeNames;
                } else {
                    currentRuleAttributeValue = selectedAttributeNames;
                }
                currentRuleAttributeId = selectedAttributeId;
                currentRuleAttributeDataType = selectedAttributeDataType;
            } else {
                currentRuleAttributeValue =  rowDTO.getAttributeValue();
                currentRuleAttributeId =  rowDTO.getAttributeId();
                currentRuleAttributeDataType = rowDTO.getAttributeDataType();
            }
            currentRuleCombineFunction =  rowDTO.getCombineFunction();
        }

        BasicTargetDTO targetRuleDTO = ruleDTO.getTargetDTO();
        
        if(targetRuleDTO != null  && targetRuleDTO.getRowDTOList() != null &&
                                                targetRuleDTO.getRowDTOList().size() > 0){            
            RowDTO rowDTO = targetRuleDTO.getRowDTOList().get(0);
            currentRuleTargetCategory = rowDTO.getCategory();
            currentRuleTargetPreFunction = rowDTO.getPreFunction();
            currentRuleTargetFunction = rowDTO.getFunction();
            if(rowDTO.isNotCompleted()){
                if(rowDTO.getAttributeValue() != null && rowDTO.getAttributeValue().trim().length() > 0){
                    currentRuleTargetAttributeValue = rowDTO.getAttributeValue() + "," + selectedAttributeNames;
                } else {
                    currentRuleTargetAttributeValue = selectedAttributeNames;
                }                 
                currentRuleTargetAttributeId = selectedAttributeId;
                currentRuleTargetAttributeDataType = selectedAttributeDataType;
            } else {
                currentRuleTargetAttributeValue =  rowDTO.getAttributeValue();
                currentRuleTargetAttributeId =  rowDTO.getAttributeId();
                currentRuleTargetAttributeDataType = rowDTO.getAttributeDataType();
            }
            currentRuleTargetCombineFunction =  rowDTO.getCombineFunction();
        }

        List<ObligationDTO> obligationRuleDTOs = ruleDTO.getObligationDTOs();

        if(obligationRuleDTOs != null && obligationRuleDTOs.size() > 0){
            ObligationDTO dto = obligationRuleDTOs.get(0);
            currentRuleObligationType = dto.getType();
            currentRuleObligationId = dto.getObligationId();
            currentRuleObligationAttributeValue = dto.getAttributeValue();
            currentRuleObligationAttributeId = dto.getResultAttributeId();
        }
    }

    if(obligationDTOs != null && obligationDTOs.size() > 0){
        ObligationDTO dto = obligationDTOs.get(0);
        currentObligationType = dto.getType();
        currentObligationId = dto.getObligationId();
        currentObligationEffect = dto.getEffect();
        currentObligationAttributeValue = dto.getAttributeValue();
        currentObligationAttributeId = dto.getResultAttributeId();                
    } else {
        obligationDTOs = null;
    }

    if(extendAttributeDTOs != null && extendAttributeDTOs.size() > 0){
        ExtendAttributeDTO dto = extendAttributeDTOs.get(0);
        currentDynamicId = dto.getId();
        currentDynamicSelector = dto.getSelector();
        if(PolicyEditorConstants.DYNAMIC_SELECTOR_FUNCTION.equals(currentDynamicSelector)){
            currentDynamicFunction = dto.getFunction();
            currentDynamicAttributeValue = dto.getAttributeValue();
        } else {
            currentDynamicCategory = dto.getCategory();
        }
        currentDynamicAttributeId = dto.getAttributeId();
        currentDynamicAttributeDataType = dto.getDataType();
    } else {
        extendAttributeDTOs = null;
    }

%>

<fmt:bundle basename="org.wso2.carbon.identity.entitlement.ui.i18n.Resources">
<carbon:breadcrumb
        label="create.basic.policy"
        resourceBundle="org.wso2.carbon.identity.entitlement.ui.i18n.Resources"
        topPage="false"
        request="<%=request%>"/>
<script type="text/javascript" src="../carbon/admin/js/breadcrumbs.js"></script>
<script type="text/javascript" src="../carbon/admin/js/cookies.js"></script>
<script type="text/javascript" src="resources/js/main.js"></script>
<!--Yahoo includes for dom event handling-->
<script src="../yui/build/yahoo-dom-event/yahoo-dom-event.js" type="text/javascript"></script>
<script src="../entitlement/js/policy-editor.js" type="text/javascript"></script>
<link href="../entitlement/css/entitlement.css" rel="stylesheet" type="text/css" media="all"/>

<script type="text/javascript">

function orderRuleElement() {

}


function submitForm() {
    preSubmit();
    if (doValidationPolicyNameOnly()) {
        document.dataForm.action = "update-rule.jsp?nextPage=finish&ruleId=";
        document.dataForm.submit();
    }
}

function doCancel() {
    location.href = 'index.jsp';
}

function doValidation() {

    var value = document.getElementsByName("policyName")[0].value;
    if (value == '') {
        CARBON.showWarningDialog('<fmt:message key="policy.name.is.required"/>');
        return false;
    }

    value = document.getElementsByName("ruleId")[0].value;
    if (value == '') {
        CARBON.showWarningDialog('<fmt:message key="rule.id.is.required"/>');
        return false;
    }

    return true;
}

function doValidationPolicyNameOnly() {

    var value = document.getElementsByName("policyName")[0].value;
    if (value == '') {
        CARBON.showWarningDialog('<fmt:message key="policy.name.is.required"/>');
        return false;
    }

    return true;
}

function doUpdate() {
    preSubmit();
    if (doValidation()) {
        document.dataForm.action = "update-rule.jsp?nextPage=policy-editor&completedRule=true&updateRule=true";
        document.dataForm.submit();
    }
}

function doCancelRule() {
    preSubmit();
    location.href= "update-rule.jsp?nextPage=policy-editor&ruleId=";
}

function deleteRule(ruleId) {
    preSubmit();
    document.dataForm.action = "update-rule.jsp?nextPage=delete-rule-entry&ruleId=" + ruleId;
    document.dataForm.submit();
}

function editRule(ruleId) {
    preSubmit();
    document.dataForm.action = "update-rule.jsp?nextPage=policy-editor&editRule=true&ruleId=" + ruleId;
    document.dataForm.submit();
}

function doAdd() {
    preSubmit();
    if (doValidation()) {
        document.dataForm.action = "update-rule.jsp?nextPage=policy-editor&completedRule=true";
        document.dataForm.submit();
    }
}

function selectAttributesForRule(index) {
    preSubmit();
    if (doValidationPolicyNameOnly()) {
        document.dataForm.action = "update-rule.jsp?nextPage=select_attribute_values&updateRule=true&ruleRowIndex="
                + index ;
        document.dataForm.submit();
    }
}

function selectAttributesForRuleTarget(index) {
    preSubmit();
    if (doValidationPolicyNameOnly()) {
        document.dataForm.action = "update-rule.jsp?nextPage=select_attribute_values&updateRule=true&targetRuleRowIndex="
                + index;
        document.dataForm.submit();
    }
}

function preSubmit(){
    
    var  multipleTargetTable = jQuery('#multipleTargetTable tr').last().attr('data-value');
    var  multipleRuleTargetTable = jQuery('#multipleRuleTargetTable tr').last().attr('data-value');
    var  multipleRuleTable = jQuery('#multipleRuleTable tr').last().attr('data-value');
    var  obligationRuleTable = jQuery('#obligationRuleTable tr').last().attr('data-value');
    var  obligationTable = jQuery('#obligationTable tr').last().attr('data-value');

    var array =  jQuery('.newTargetRow');
    for(var i = 0; i < array.length; i++){
        jQuery(array[i]).removeAttr('disabled');
    }

    array =  jQuery('.newRuleTargetRow');
    for(i = 0; i < array.length; i++){
        jQuery(array[i]).removeAttr('disabled');
    }

    array =  jQuery('.newRuleRow');
    for(i = 0; i < array.length; i++){
        jQuery(array[i]).removeAttr('disabled');
    }

    var ruleElementOrder = new Array();
    var tmp = jQuery("#dataTable tbody tr input");
    for (var j = 0; j < tmp.length; j++) {
        ruleElementOrder.push(tmp[j].value);
    }

    jQuery('#mainTable > tbody:last').append('<tr><td><input type="hidden" name="maxTargetRows" id="maxTargetRows" value="' + multipleTargetTable +'"/></td></tr>');
    jQuery('#mainTable > tbody:last').append('<tr><td><input type="hidden" name="maxTargetRuleRows" id="maxTargetRuleRows" value="' + multipleRuleTargetTable +'"/></td></tr>');
    jQuery('#mainTable > tbody:last').append('<tr><td><input type="hidden" name="maxRuleRows" id="maxRuleRows" value="' + multipleRuleTable +'"/></td></tr>')  ;
    jQuery('#mainTable > tbody:last').append('<tr><td><input type="hidden" name="maxObligationRuleRows" id="maxObligationRuleRows" value="' + obligationRuleTable +'"/></td></tr>') ;
    jQuery('#mainTable > tbody:last').append('<tr><td><input type="hidden" name="maxObligationRows" id="maxObligationRows" value="' + obligationTable +'"/></td></tr>') ;
    jQuery('#mainTable > tbody:last').append('<tr><td><input type="hidden" name="ruleElementOrder" id="ruleElementOrder" value="' + ruleElementOrder +'"/></td></tr>') ;
}

    function selectAttributesForTarget(index) {
        preSubmit();
        if (doValidationPolicyNameOnly()) {
            document.dataForm.action = "update-rule.jsp?nextPage=select_attribute_values&ruleId=&targetRowIndex="
                    + index;
            document.dataForm.submit();
        }
    }

    function updownthis(thislink, updown) {
        var sampleTable = document.getElementById('dataTable');
        var clickedRow = thislink.parentNode.parentNode;
        var addition = -1;
        if (updown == "down") {
            addition = 1;
        }
        var otherRow = sampleTable.rows[clickedRow.rowIndex + addition];
        var numrows = jQuery("#dataTable tbody tr").length;
        if (numrows <= 1) {
            return;
        }
        if (clickedRow.rowIndex == 1 && updown == "up") {
            return;
        } else if (clickedRow.rowIndex == numrows && updown == "down") {
            return;
        }
        var rowdata_clicked = new Array();
        for (var i = 0; i < clickedRow.cells.length; i++) {
            rowdata_clicked.push(clickedRow.cells[i].innerHTML);
            clickedRow.cells[i].innerHTML = otherRow.cells[i].innerHTML;
        }
        for (i = 0; i < otherRow.cells.length; i++) {
            otherRow.cells[i].innerHTML = rowdata_clicked[i];
        }
    }

</script>
<div id="middle">
<h2><fmt:message key="create.entitlement.policy"/></h2>

<div id="workArea">
<div class="goToAdvance">
    <a class='icon-link' href="../entitlement/add-policy.jsp"
       style='background-image:url(images/advanceview.png);float:none'><fmt:message
            key="use.xml.view"/></a>
</div>
<form id="dataForm" name="dataForm" method="post" action="">
<table id="mainTable" class="styledLeft noBorders">
<tr>
    <td class="leftCol-med"><fmt:message key='policy.name'/><span class="required">*</span></td>
    <%
        if (entitlementPolicyBean.getPolicyName() != null) {
    %>
    <td><input type="text" name="policyName" id="policyName"
               value="<%=entitlementPolicyBean.getPolicyName()%>" class="text-box-big"/></td>
    <%
    } else {
    %>
    <td><input type="text" name="policyName" id="policyName" class="text-box-big"/></td>
    <%
        }
    %>
</tr>

<tr>
    <td><fmt:message key="rule.combining.algorithm"/></td>
    <td>
        <select id="algorithmName" name="algorithmName" class="text-box-big">
            <%
                if (ruleCombingAlgorithm != null && ruleCombingAlgorithm.length > 0) {
                    for (String algorithmName : ruleCombingAlgorithm) {
                        if (algorithmName.equals(entitlementPolicyBean.getAlgorithmName())) {
            %>
            <option value="<%=algorithmName%>"
                    selected="selected"><%=entitlementPolicyBean.getAlgorithmName()%>
            </option>
            <%
            } else {
            %>
            <option value="<%=algorithmName%>"><%=algorithmName%>
            </option>
            <%
                        }
                    }
                }
            %>
        </select>
    </td>
</tr>

<tr>
    <td class="leftCol-small" style="vertical-align:top !important"><fmt:message
            key='policy.description'/></td>
    <%
        if (entitlementPolicyBean.getPolicyDescription() != null) {
    %>
    <td><textarea name="policyDescription" id="policyDescription"
                  value="<%=entitlementPolicyBean.getPolicyDescription()%>"
                  class="text-box-big"><%=entitlementPolicyBean.getPolicyDescription()%>
    </textarea></td>
    <%
    } else {
    %>
    <td><textarea type="text" name="policyDescription" id="policyDescription"
                  class="text-box-big"></textarea></td>
    <%
        }
    %>
</tr>


<tr>
    <td colspan="2">
        <script type="text/javascript">
            jQuery(document).ready(function() {
            <%if(targetDTO == null){%>
                jQuery("#newTargetLinkRow").hide();
            <%}else{ %>
                jQuery("#newTargetLinkRow").show();
            <% } %>

            <%if(ruleDTO == null){%>
                jQuery("#newRuleLinkRow").hide();
            <%}else{ %>
                jQuery("#newRuleLinkRow").show();
            <% } %>

            <%if(obligationDTOs == null){%>
                jQuery("#newObligationLinkRow").hide();
            <%}else{ %>
                jQuery("#newObligationLinkRow").show();
            <% } %>

            <%if(extendAttributeDTOs == null){%>
                jQuery("#newExtendLinkRow").hide();
            <%}else{ %>
                jQuery("#newExtendLinkRow").show();
            <% } %>
                /*Hide (Collapse) the toggle containers on load use show() insted of hide() 	in the 			above code if you want to keep the content section expanded. */

                jQuery("h2.trigger").click(function() {
                    if (jQuery(this).next().is(":visible")) {
                        this.className = "active trigger";
                    } else {
                        this.className = "trigger";
                    }

                    jQuery(this).next().slideToggle("fast");
                    return false; //Prevent the browser jump to the link anchor
                });
            });
        </script>
        <h2 class="trigger  <%if(targetDTO == null){%>active<%} %>"><a
                href="#"><fmt:message key="policy.apply.to"/></a></h2>

        <div class="toggle_container" style="padding:0;margin-bottom:10px;" id="newTargetLinkRow">

            <table class="noBorders" cellspacing="0" style="width:100%;padding-top:5px;">
                <tr>
                    <td>
                        <table id="multipleTargetTable" name="multipleTargetTable" class="normal"
                               style="padding-left:0px !important">
                            <tr data-value="0">

                                <td style="padding-left:0px !important;padding-right:0px !important">
                                    <select id="targetCategory_0" name="targetCategory_0">
                                        <%
                                            for (String category : categories) {
                                                if (currentCategory != null && category.equals(currentCategory)) {
                                        %>
                                        <option value="<%=category%>" selected="selected"><%=category%></option>
                                        <%
                                                } else {
                                        %>
                                        <option value="<%=category%>"><%=category%></option>
                                        <%
                                                    }
                                                }
                                        %>
                                    </select>
                                </td>


                                <td style="padding-left:0px !important;padding-right:0px !important">
                                    <select id="targetPreFunction_0" name="targetPreFunction_0">
                                        <%
                                            for (String targetPreFunction : targetPreFunctions) {
                                                if (currentPreFunction != null && targetPreFunction.equals(currentPreFunction)) {
                                        %>
                                        <option value="<%=targetPreFunction%>"
                                                selected="selected"><%=targetPreFunction%>
                                        </option>
                                        <%
                                        } else {
                                        %>
                                        <option value="<%=targetPreFunction%>"><%=targetPreFunction%>
                                        </option>
                                        <%
                                                }
                                            }
                                        %>
                                    </select>
                                </td>


                                <td style="padding-left:0px !important;padding-right:0px !important">
                                    <select id="targetFunction_0" name="targetFunction_0"
                                            class="leftCol-small">
                                        <%
                                            for (String targetFunction : targetFunctions) {
                                                if (currentFunction != null && targetFunction.equals(currentFunction)) {
                                        %>
                                        <option value="<%=targetFunction%>"
                                                selected="selected"><%=targetFunction%>
                                        </option>
                                        <%
                                        } else {
                                        %>
                                        <option value="<%=targetFunction%>"><%=targetFunction%>
                                        </option>
                                        <%
                                                }
                                            }
                                        %>
                                    </select>
                                </td>


                                <td style="padding-left:0px !important;padding-right:0px !important">
                                    <%
                                        if (currentAttributeValue != null && !"".equals(currentAttributeValue)) {

                                    %>
                                    <input type="text" size="60" name="targetAttributeValue_0"
                                           id="targetAttributeValue_0"
                                           value="<%=currentAttributeValue%>" class="text-box-big"/>
                                    <%
                                    } else {
                                    %>
                                    <input type="text" size="60" name="targetAttributeValue_0"
                                           id="targetAttributeValue_0" class="defaultText text-box-big" />

                                    <%
                                        }
                                    %>
                                </td>
                                <td>
                                    <a title="Select Resources Names" class='icon-link'
                                       onclick='selectAttributesForTarget(0);'
                                       style='background-image:url(images/registry.gif);'></a>
                                </td>

                                <td style="padding-left:0px !important;padding-right:0px !important">
                                    <select id="targetCombineFunctions_0" name="targetCombineFunctions_0"
                                            class="newTargetRow" onchange="createNewTargetRow(this.options[this.selectedIndex].value)">
                                        <%
                                            for (String combineFunction : combineFunctions) {
                                                if (currentCombineFunction != null && combineFunction.equals(currentCombineFunction)) {
                                        %>
                                        <option value="<%=combineFunction%>"
                                                selected="selected"><%=combineFunction%>
                                        </option>
                                        <%
                                        } else {
                                        %>
                                        <option value="<%=combineFunction%>"><%=combineFunction%>
                                        </option>
                                        <%
                                                }
                                            }
                                        %>
                                    </select>
                                </td>
                                <td>
                                    <input type="hidden" name="targetAttributeId_0"
                                           id="targetAttributeId_0" value="<%=currentAttributeId%>"/>
                                </td>

                                <td>
                                    <input type="hidden" name="targetAttributeTypes_0"
                                           id="targetAttributeTypes_0"
                                           value="<%=currentAttributeDataType%>"/>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
<%

    if(targetDTO != null){
        List<RowDTO> rowDTOs = targetDTO.getRowDTOList();
        if(rowDTOs != null && rowDTOs.size() > 0){
            rowDTOs.remove(0);
            for(RowDTO rowDTO : rowDTOs){
                currentCategory = rowDTO.getCategory();
                currentPreFunction = rowDTO.getPreFunction();
                currentFunction = rowDTO.getFunction();
                if(rowDTO.isNotCompleted()){
                    if(rowDTO.getAttributeValue() != null && rowDTO.getAttributeValue().trim().length() > 0){
                        currentAttributeValue = rowDTO.getAttributeValue() + "," + selectedAttributeNames;
                    } else {
                        currentAttributeValue = selectedAttributeNames;
                    }
                    currentAttributeId = selectedAttributeId;
                    currentAttributeDataType = selectedAttributeDataType;
                } else {
                    currentAttributeValue =  rowDTO.getAttributeValue();
                    currentAttributeId =  rowDTO.getAttributeId();
                    currentAttributeDataType = rowDTO.getAttributeDataType();
                }
                currentCombineFunction =  rowDTO.getCombineFunction();

            %>
                <script type="text/javascript">
                    function createNextTargetRow() {
                        jQuery('.newTargetRow').attr('disabled','disabled');
                        var rowIndex =  jQuery('#multipleTargetTable tr').last().attr('data-value');
                        var index = parseInt(rowIndex, 10) + 1;
                        jQuery('#multipleTargetTable > tbody:last').append('<tr  data-value="' + index +'"><td style="padding-left:0px !important;padding-right:0px !important"><select id="targetCategory_'  + index + '" name="targetCategory_'  + index + '" > <%for (String category : categories) { if(currentCategory != null && category.equals(currentCategory)){%> <option value="<%=category%>" selected="selected"><%=currentCategory%> </option> <%} else {%> <option value="<%=category%>"><%=category%> </option> <%} }%></select></td>' +
                                '<td style="padding-left:0px !important;padding-right:0px !important"><select id="targetPreFunction_'  + index + '" name="targetPreFunction_'  + index + '" ><%for (String targetPreFunction : targetPreFunctions) {if (currentPreFunction != null && targetPreFunction.equals(currentPreFunction)) {%><option value="<%=targetPreFunction%>" selected="selected"><%=targetPreFunction%></option><%} else {%><option value="<%=targetPreFunction%>"><%=targetPreFunction%></option><%}}%></select></td>' +
                                '<td style="padding-left:0px !important;padding-right:0px !important"><select id="targetFunction_'  + index + '" name="targetFunction_'  + index + '" class="leftCol-small"><%for (String targetFunction : targetFunctions) {if (currentFunction != null && targetFunction.equals(currentFunction)) {%><option value="<%=targetFunction%>" selected="selected"><%=targetFunction%></option><%} else {%><option value="<%=targetFunction%>"><%=targetFunction%></option><%}}%></select></td>' +
                                '<td style="padding-left:0px !important;padding-right:0px !important"><%if (currentAttributeValue != null && !"".equals(currentAttributeValue)) {%><input type="text" size="60" name="targetAttributeValue_'  + index + '" id="targetAttributeValue_'  + index + '" value="<%=currentAttributeValue%>" class="text-box-big"/><%} else {%><input type="text" size="60" name="targetAttributeValue_'  + index + '" id="targetAttributeValue_'  + index + '" class="text-box-big"/><%}%></td>' +
                                '<td><a title="Select Resources Names" class="icon-link" onclick="selectAttributesForTarget(' + index + ');" style="background-image:url(images/registry.gif);"></a></td>' +
                                '<td style="padding-left:0px !important;padding-right:0px !important"><select id="targetCombineFunctions_'  + index + '" name="targetCombineFunctions_'  + index + '" class="newTargetRow " onchange="createNewTargetRow(this.options[this.selectedIndex].value)"><%for (String combineFunction : combineFunctions) {if (currentCombineFunction != null && combineFunction.equals(currentCombineFunction)) {%><option value="<%=combineFunction%>" selected="selected"><%=combineFunction%></option><%} else {%><option value="<%=combineFunction%>"><%=combineFunction%></option><%}}%></select></td>' +
                                '<td><a onclick="removeRow(this)" style="background-image:url(images/delete.gif);" type="button" class="icon-link"></a></td>' +
                                '<td><input type="hidden" name="targetAttributeId_'  + index +  '" id="targetAttributeId_'  + index + '" value="<%=currentAttributeId%>"/></td>' +
                                '<td><input type="hidden" name="targetAttributeTypes_'  + index + '" id="targetAttributeTypes_'  + index +  '" value="<%=currentAttributeDataType%>"/></td>' +                                
                                '</tr>');
                    }
                    createNextTargetRow();
                </script>
            <%
            }
        }
    }
%>
        </div>

    </td>
</tr>
<tr>
<td colspan="2" style="margin-top:10px;">
<h2 class="trigger  <%if(ruleDTO == null){%>active<%} %>"><a href="#"><fmt:message
        key="add.new.entitlement.rule"/></a></h2>

<div class="toggle_container" id="newRuleLinkRow">


    <table class="noBorders" id="ruleTable" style="width: 100%">
        <body>
        <tr>
            <td class="formRow" style="padding:0 !important">
                <table class="normal" cellspacing="0">

                    <tr>
                        <td class="leftCol-small"><fmt:message key='rule.name'/><span
                                class="required">*</span>
                        </td>
                        <td>
                            <%
                                if (ruleId != null && !ruleId.trim().equals("") && !ruleId.trim().equals("null")) {
                            %>
                            <input type="text" name="ruleId" id="ruleId" class="text-box-big"
                                   value="<%=ruleDTO.getRuleId()%>"/>
                            <%
                            } else {
                            %>
                            <input type="text" name="ruleId" id="ruleId" class="text-box-big"/>
                            <%
                                }
                            %>
                        </td>
                    </tr>

                    <tr>
                        <td><fmt:message key="rule.effect"/></td>
                        <td colspan="4">
                            <select id="ruleEffect" name="ruleEffect" class="leftCol-small">
                                <%
                                    if (ruleEffects != null) {
                                        for (String effect : ruleEffects) {
                                            if (effect.equals(ruleEffect)) {

                                %>
                                <option value="<%=effect%>" selected="selected"><%=ruleEffect%>
                                </option>
                                <%
                                } else {

                                %>
                                <option value="<%=effect%>"><%=effect%>
                                </option>
                                <%
                                            }
                                        }
                                    }
                                %>
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="5"><div class="sectionHelp"><fmt:message key="rule.target"/></div></td>
                    </tr>
                    <tr>
                        <td  colspan="5">
                        <table id="multipleRuleTargetTable" name="multipleRuleTargetTable" class="normal"
                               style="padding-left:0px !important">
                            <tr data-value="0">

                                <td style="padding-left:0px !important;padding-right:0px !important">
                                    <select id="ruleTargetCategory_0" name="ruleTargetCategory_0">
                                        <%
                                            for (String category : categories) {
                                                if (currentRuleTargetCategory != null && category.equals(currentRuleTargetCategory)) {
                                        %>
                                        <option value="<%=category%>"
                                                selected="selected"><%=category%>
                                        </option>
                                        <%
                                        } else {
                                        %>
                                        <option value="<%=category%>"><%=category%>
                                        </option>
                                        <%
                                                }
                                            }
                                        %>
                                    </select>
                                </td>

                                <td style="padding-left:0px !important;padding-right:0px !important">
                                    <select id="ruleTargetPreFunction_0" name="ruleTargetPreFunction_0">
                                        <%
                                            for (String targetPreFunction : targetPreFunctions) {
                                                if (currentRuleTargetPreFunction != null && targetPreFunction.equals(currentRuleTargetPreFunction)) {
                                        %>
                                        <option value="<%=targetPreFunction%>"
                                                selected="selected"><%=targetPreFunction%>
                                        </option>
                                        <%
                                        } else {
                                        %>
                                        <option value="<%=targetPreFunction%>"><%=targetPreFunction%>
                                        </option>
                                        <%
                                                }
                                            }
                                        %>
                                    </select>
                                </td>

                                <td style="padding-left:0px !important;padding-right:0px !important">
                                    <select id="ruleTargetFunction_0" name="ruleTargetFunction_0"
                                            class="leftCol-small">
                                        <%
                                            for (String targetFunction : targetFunctions) {
                                                if (currentRuleTargetFunction != null && targetFunction.equals(currentRuleTargetFunction)) {
                                        %>
                                        <option value="<%=targetFunction%>" selected="selected"><%=targetFunction%></option>
                                        <%
                                        } else {
                                        %>
                                        <option value="<%=targetFunction%>"><%=targetFunction%></option>
                                        <%
                                                }
                                            }
                                        %>
                                    </select>
                                </td>

                                <td style="padding-left:0px !important;padding-right:0px !important">
                                    <%
                                        if (currentRuleTargetAttributeValue != null && currentRuleTargetAttributeValue.trim().length() > 0) {

                                    %>
                                    <input type="text" size="60" name="ruleTargetAttributeValue_0"
                                           id="ruleTargetAttributeValue_0"
                                           value="<%=currentRuleTargetAttributeValue%>" class="text-box-big"/>
                                    <%
                                    } else {
                                    %>
                                    <input type="text" size="60" name="ruleTargetAttributeValue_0"
                                           id="ruleTargetAttributeValue_0"
                                           class="text-box-big" />

                                    <%
                                        }
                                    %>
                                </td>
                                <td>
                                    <a title="Select Resources Names" class='icon-link'
                                       onclick='selectAttributesForRuleTarget(0);'
                                       style='background-image:url(images/registry.gif);'></a>
                                </td>

                                <td style="padding-left:0px !important;padding-right:0px !important">
                                    <select id="ruleTargetCombineFunctions_0" name="ruleTargetCombineFunctions_0"
                                            class="newRuleTargetRow" onchange="createNewRuleTargetRow(this.options[this.selectedIndex].value)">
                                        <%
                                            for (String combineFunction : combineFunctions) {
                                                if (currentRuleTargetCombineFunction != null && combineFunction.equals(currentRuleTargetCombineFunction)) {
                                        %>
                                        <option value="<%=combineFunction%>"
                                                selected="selected"><%=combineFunction%>
                                        </option>
                                        <%
                                        } else {
                                        %>
                                        <option value="<%=combineFunction%>"><%=combineFunction%>
                                        </option>
                                        <%
                                                }
                                            }
                                        %>
                                    </select>
                                </td>
                                <td>
                                    <input type="hidden" name="ruleTargetAttributeId_0"
                                           id="ruleTargetAttributeId_0" value="<%=currentRuleTargetAttributeId%>"/>
                                </td>

                                <td>
                                    <input type="hidden" name="ruleTargetAttributeTypes_0"
                                           id="ruleTargetAttributeTypes_0"
                                           value="<%=currentRuleTargetAttributeDataType%>"/>
                                </td>                                
                            </tr>
                        </table>
<%

    if(ruleDTO != null){
        BasicTargetDTO ruleTargetDTO = ruleDTO.getTargetDTO();
        if(ruleTargetDTO != null && ruleTargetDTO.getRowDTOList() != null && ruleTargetDTO.getRowDTOList().size() > 0){
            List<RowDTO> rowDTOs = ruleTargetDTO.getRowDTOList();
            rowDTOs.remove(0);
            for(RowDTO rowDTO : rowDTOs){
                currentRuleTargetCategory = rowDTO.getCategory();
                currentRuleTargetPreFunction = rowDTO.getPreFunction();
                currentRuleTargetFunction = rowDTO.getFunction();
                if(rowDTO.isNotCompleted()){
                    if(rowDTO.getAttributeValue() != null &&
                                                rowDTO.getAttributeValue().trim().length() > 0){
                        currentRuleTargetAttributeValue = rowDTO.getAttributeValue() + "," +
                                                                        selectedAttributeNames;
                    } else {
                        currentRuleTargetAttributeValue = selectedAttributeNames;
                    }                    
                    currentRuleTargetAttributeId = selectedAttributeId;
                    currentRuleTargetAttributeDataType = selectedAttributeDataType;
                } else {
                    currentRuleTargetAttributeValue =  rowDTO.getAttributeValue();
                    currentRuleTargetAttributeId =  rowDTO.getAttributeId();
                    currentRuleTargetAttributeDataType = rowDTO.getAttributeDataType();
                }
                currentRuleTargetCombineFunction =  rowDTO.getCombineFunction();

            %>
            <script type="text/javascript">
                function createNextRuleTargetRow() {
                    jQuery('.newRuleTargetRow').attr('disabled','disabled');
                    var rowIndex =  jQuery('#multipleRuleTargetTable tr').last().attr('data-value');
                    var index = parseInt(rowIndex, 10) + 1;
                    jQuery('#multipleRuleTargetTable > tbody:last').append('<tr data-value="'+ index +'"><td style="padding-left:0px !important;padding-right:0px !important"><select id="ruleTargetCategory_'  + index + '" name="ruleTargetCategory_'  + index + '"> <%for (String category : categories) { if(currentRuleTargetCategory != null && category.equals(currentRuleTargetCategory)){%> <option value="<%=category%>" selected="selected"><%=category%> </option> <%} else {%> <option value="<%=category%>"><%=category%> </option> <%} }%></select></td>' +
                        '<td style="padding-left:0px !important;padding-right:0px !important"><select id="ruleTargetPreFunction_'  + index + '" name="ruleTargetPreFunction_'  + index + '" ><%for (String targetPreFunction : targetPreFunctions) {if (currentRuleTargetPreFunction != null && targetPreFunction.equals(currentRuleTargetPreFunction)) {%><option value="<%=targetPreFunction%>" selected="selected"><%=targetPreFunction%></option><%} else {%><option value="<%=targetPreFunction%>"><%=targetPreFunction%></option><%}}%></select></td>' +
                        '<td style="padding-left:0px !important;padding-right:0px !important"><select id="ruleTargetFunction_'  + index + '" name="ruleTargetFunction_'  + index + '" class="leftCol-small"><%for (String targetFunction : targetFunctions) {if (currentRuleTargetFunction != null && targetFunction.equals(currentRuleTargetFunction)) {%><option value="<%=targetFunction%>" selected="selected"><%=targetFunction%></option><%} else {%><option value="<%=targetFunction%>"><%=targetFunction%></option><%}}%></select></td>' +
                        '<td style="padding-left:0px !important;padding-right:0px !important"><%if (currentRuleTargetAttributeValue != null && !"".equals(currentRuleTargetAttributeValue)) {%><input type="text" size="60" name="ruleTargetAttributeValue_'  + index + '" id="ruleTargetAttributeValue_'  + index + '" value="<%=currentRuleTargetAttributeValue%>" class="text-box-big"/><%} else {%><input type="text" size="60" name="ruleTargetAttributeValue_'  + index + '" id="ruleTargetAttributeValue_'  + index + '" class="text-box-big"/><%}%></td>' +
                        '<td><a title="Select Resources Names" class="icon-link" onclick="selectAttributesForRuleTarget(' + index + ');" style="background-image:url(images/registry.gif);"></a></td>' +
                        '<td style="padding-left:0px !important;padding-right:0px !important"><select id="ruleTargetCombineFunctions_'  + index + '" name="ruleTargetCombineFunctions_'  + index + '" class="newRuleTargetRow " onchange="createNewRuleTargetRow(this.options[this.selectedIndex].value)"><%for (String combineFunction : combineFunctions) {if (currentRuleTargetCombineFunction != null && combineFunction.equals(currentRuleTargetCombineFunction)) {%><option value="<%=combineFunction%>" selected="selected"><%=combineFunction%></option><%} else {%><option value="<%=combineFunction%>"><%=combineFunction%></option><%}}%></select></td>' +
                        '<td><a onclick="removeRow(this)" style="background-image:url(images/delete.gif);" type="button" class="icon-link"></a></td>' +
                        '<td><input type="hidden" name="ruleTargetAttributeId_'  + index +  '" id="ruleTargetAttributeId_'  + index + '" value="<%=currentRuleTargetAttributeId%>"/></td>' +
                        '<td><input type="hidden" name="ruleTargetAttributeTypes_'  + index + '" id="ruleTargetAttributeTypes_'  + index +  '" value="<%=currentRuleTargetAttributeDataType%>"/></td>' +
                        '</tr>');
                }
                createNextRuleTargetRow()
            </script>
            <%
            }
        }
    }

%>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="5"><div class="sectionHelp"><fmt:message key="rule.condition"/></div></td>
                    </tr>
                    <tr>
                        <td  colspan="5">
                        <table id="multipleRuleTable" name="multipleRuleTable" class="normal"
                               style="padding-left:0px !important">
                            <tr data-value="0">

                                <td style="padding-left:0px !important;padding-right:0px !important">
                                    <select id="ruleCategory_0" name="ruleCategory_0">
                                        <%
                                            for (String category : categories) {
                                                if (currentRuleCategory != null && category.equals(currentRuleCategory)) {
                                        %>
                                        <option value="<%=category%>"
                                                selected="selected"><%=category%>
                                        </option>
                                        <%
                                        } else {
                                        %>
                                        <option value="<%=category%>"><%=category%>
                                        </option>
                                        <%
                                                }
                                            }
                                        %>
                                    </select>
                                </td>

                                <td style="padding-left:0px !important;padding-right:0px !important">
                                    <select id="rulePreFunction_0" name="rulePreFunction_0">
                                        <%
                                            for (String rulePreFunction : rulePreFunctions) {
                                                if (currentRulePreFunction != null && rulePreFunction.equals(currentRulePreFunction)) {
                                        %>
                                        <option value="<%=rulePreFunction%>"
                                                selected="selected"><%=rulePreFunction%>
                                        </option>
                                        <%
                                        } else {
                                        %>
                                        <option value="<%=rulePreFunction%>"><%=rulePreFunction%>
                                        </option>
                                        <%
                                                }
                                            }
                                        %>
                                    </select>
                                </td>

                                <td style="padding-left:0px !important;padding-right:0px !important">
                                    <select id="ruleFunction_0" name="ruleFunction_0"
                                            class="leftCol-small">
                                        <%
                                            for (String ruleFunction : ruleFunctions) {
                                                if (currentRuleFunction != null && ruleFunction.equals(currentRuleFunction)) {
                                        %>
                                        <option value="<%=ruleFunction%>" selected="selected"><%=ruleFunction%></option>
                                        <%
                                        } else {
                                        %>
                                        <option value="<%=ruleFunction%>"><%=ruleFunction%></option>
                                        <%
                                                }
                                            }
                                        %>
                                    </select>
                                </td>

                                <td style="padding-left:0px !important;padding-right:0px !important">
                                    <%
                                        if (currentRuleAttributeValue != null && currentRuleAttributeValue.trim().length() > 0) {

                                    %>
                                    <input type="text" size="60" name="ruleAttributeValue_0"
                                           id="ruleAttributeValue_0"
                                           value="<%=currentRuleAttributeValue%>" class="text-box-big"/>
                                    <%
                                    } else {
                                    %>
                                    <input type="text" size="60" name="ruleAttributeValue_0"
                                           id="ruleAttributeValue_0"
                                           class="text-box-big" />

                                    <%
                                        }
                                    %>
                                </td>
                                <td>
                                    <a title="Select Resources Names" class='icon-link'
                                       onclick='selectAttributesForRule(0);'
                                       style='background-image:url(images/registry.gif);'></a>
                                </td>
                                <td style="padding-left:0px !important;padding-right:0px !important">
                                    <select id="ruleCombineFunctions_0" name="ruleCombineFunctions_0"
                                            class="newRuleRow" onchange="createNewRuleRow(this.options[this.selectedIndex].value)">
                                        <%
                                            for (String combineFunction : combineFunctions) {
                                                if (currentRuleCombineFunction != null && combineFunction.equals(currentRuleCombineFunction)) {
                                        %>
                                        <option value="<%=combineFunction%>"
                                                selected="selected"><%=combineFunction%>
                                        </option>
                                        <%
                                        } else {
                                        %>
                                        <option value="<%=combineFunction%>"><%=combineFunction%></option>
                                        <%
                                                }
                                            }
                                        %>
                                    </select>
                                </td>
                                <td>
                                    <input type="hidden" name="ruleAttributeId_0"
                                           id="ruleAttributeId_0" value="<%=currentRuleAttributeId%>"/>
                                </td>

                                <td>
                                    <input type="hidden" name="ruleAttributeTypes_0"
                                           id="ruleAttributeTypes_0"
                                           value="<%=currentRuleAttributeDataType%>"/>
                                </td>                                
                            </tr>
<%

    if(ruleDTO != null){
        List<RowDTO> rowDTOs = ruleDTO.getRowDTOList();
        if(rowDTOs != null && rowDTOs.size() > 0){
            rowDTOs.remove(0);
            for(RowDTO rowDTO : rowDTOs){
                currentRuleCategory = rowDTO.getCategory();
                currentRulePreFunction = rowDTO.getPreFunction();
                currentRuleFunction = rowDTO.getFunction();
                if(rowDTO.isNotCompleted()){
                    if(rowDTO.getAttributeValue() != null && rowDTO.getAttributeValue().trim().length() > 0){
                        currentRuleAttributeValue = rowDTO.getAttributeValue() + "," + selectedAttributeNames;
                    } else {
                        currentRuleAttributeValue = selectedAttributeNames;
                    }
                    currentRuleAttributeId = selectedAttributeId;
                    currentRuleAttributeDataType = selectedAttributeDataType;
                } else {
                    currentRuleAttributeValue =  rowDTO.getAttributeValue();
                    currentRuleAttributeId =  rowDTO.getAttributeId();
                    currentRuleAttributeDataType = rowDTO.getAttributeDataType();
                }
                currentRuleCombineFunction =  rowDTO.getCombineFunction();

            %>
                <script type="text/javascript">
                    function createNextRuleRow() {
                        jQuery('.newRuleRow').attr('disabled','disabled');
                        var rowIndex =  jQuery('#multipleRuleTable tr').last().attr('data-value');
                        var index = parseInt(rowIndex, 10) + 1;
                        jQuery('#multipleRuleTable > tbody:last').append('<tr data-value="'+ index +'"><td style="padding-left:0px !important;padding-right:0px !important"><select id="ruleCategory_'  + index + '" name="ruleCategory_'  + index + '"> <%for (String category : categories) { if(currentRuleCategory != null && category.equals(currentRuleCategory)){%> <option value="<%=category%>" selected="selected"><%=category%> </option> <%} else {%> <option value="<%=category%>"><%=category%> </option> <%} }%></select></td>' +
                            '<td style="padding-left:0px !important;padding-right:0px !important"><select id="rulePreFunction_'  + index + '" name="rulePreFunction_'  + index + '" ><%for (String rulePreFunction : rulePreFunctions) {if (currentRulePreFunction != null && rulePreFunction.equals(currentRulePreFunction)) {%><option value="<%=rulePreFunction%>" selected="selected"><%=rulePreFunction%></option><%} else {%><option value="<%=rulePreFunction%>"><%=rulePreFunction%></option><%}}%></select></td>' +
                            '<td style="padding-left:0px !important;padding-right:0px !important"><select id="ruleFunction_'  + index + '" name="ruleFunction_'  + index + '" class="leftCol-small"><%for (String ruleFunction : ruleFunctions) {if (currentRuleFunction != null && ruleFunction.equals(currentRuleFunction)) {%><option value="<%=ruleFunction%>" selected="selected"><%=ruleFunction%></option><%} else {%><option value="<%=ruleFunction%>"><%=ruleFunction%></option><%}}%></select></td>' +
                            '<td style="padding-left:0px !important;padding-right:0px !important"><%if (currentRuleAttributeValue != null && !"".equals(currentRuleAttributeValue)) {%><input type="text" size="60" name="ruleAttributeValue_'  + index + '" id="ruleAttributeValue_'  + index + '" value="<%=currentRuleAttributeValue%>" class="text-box-big"/><%} else {%><input type="text" size="60" name="ruleAttributeValue_'  + index + '" id="ruleAttributeValue_'  + index + '" class="text-box-big"/><%}%></td>' +
                            '<td><a title="Select Resources Names" class="icon-link" onclick="selectAttributesForRule(' + index + ');" style="background-image:url(images/registry.gif);"></a></td>' +
                            '<td style="padding-left:0px !important;padding-right:0px !important"><select id="ruleCombineFunctions_'  + index + '" name="ruleCombineFunctions_'  + index + '" class="newRuleRow" onchange="createNewRuleRow(this.options[this.selectedIndex].value)"><%for (String combineFunction : combineFunctions) {if (currentCombineFunction != null && combineFunction.equals(currentRuleCombineFunction)) {%><option value="<%=combineFunction%>" selected="selected"><%=combineFunction%></option><%} else {%><option value="<%=combineFunction%>"><%=combineFunction%></option><%}}%></select></td>' +
                            '<td><a onclick="removeRow(this)" style="background-image:url(images/delete.gif);" type="button" class="icon-link"></a></td>' +
                            '<td><input type="hidden" name="ruleAttributeId_'  + index +  '" id="ruleAttributeId_'  + index + '" value="<%=currentRuleAttributeId%>"/></td>' +
                            '<td><input type="hidden" name="ruleAttributeTypes_'  + index + '" id="ruleAttributeTypes_'  + index +  '" value="<%=currentRuleAttributeDataType%>"/></td>' +
                            '</tr>');
                    }
                    createNextRuleRow();
                </script>
            <%
            }
        }
    }

%>
                        </table>
                        </td>
                    </tr>
                     <tr>
                        <td colspan="5"><div class="sectionHelp"><fmt:message key="rule.obligation"/></div></td>
                    </tr>
                    <tr>                       
                        <td colspan='5'>
                            <table class="ob-table">
                            <td style="width:152px;">Obligation Type</td>
                            <td style="width:148px;">Obligation Id</td>
                            <td style="width:270px;">Attribute Expression</td>
                            <td style="width:150px;">Assignment Id</td>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="5">
                            <table id="obligationRuleTable" name="obligationRuleTable" class="normal"
                                   style="padding-left:0px !important">
                                <tr data-value="0">
                                    <td style="padding-left:0px !important;padding-right:0px !important">
                                        <select id="obligationRuleType_0" name="obligationRuleType_0">
                                            <%
                                                for (String type : obligationTypes) {
                                                    if (currentRuleObligationType != null && type.equals(currentRuleObligationType)) {
                                            %>
                                            <option value="<%=type%>"
                                                    selected="selected"><%=type%>
                                            </option>
                                            <%
                                            } else {
                                            %>
                                            <option value="<%=type%>"><%=type%></option>
                                            <%
                                                    }
                                                }
                                            %>
                                        </select>
                                    </td>
                                    <td style="padding-left:0px !important;padding-right:0px !important">
                                        <%
                                            if (currentRuleObligationId != null && currentRuleObligationId.trim().length() > 0) {
                                        %>
                                            <input type="text" size="20" name="obligationRuleId_0" id="obligationRuleId_0"
                                                   value="<%=currentRuleObligationId%>" />
                                        <%
                                        } else {
                                        %>
                                            <input type="text" size="20" name="obligationRuleId_0" id="obligationRuleId_0" />
                                        <%
                                            }
                                        %>
                                    </td>

                                    <td style="padding-left:0px !important;padding-right:0px !important">
                                        <%
                                            if (currentRuleObligationAttributeValue != null && currentRuleObligationAttributeValue.trim().length() > 0) {
                                        %>
                                            <input type="text" size="40" name="obligationRuleAttributeValue_0" id="obligationRuleAttributeValue_0"
                                                   value="<%=currentRuleObligationAttributeValue%>" />
                                        <%
                                        } else {
                                        %>
                                            <input type="text" size="40" name="obligationRuleAttributeValue_0" id="obligationRuleAttributeValue_0" />
                                        <%
                                            }
                                        %>
                                    </td>
                                    <td style="padding-left:0px !important;padding-right:0px !important">
                                        <%
                                            if (currentRuleObligationAttributeId != null && currentRuleObligationAttributeId.trim().length() > 0) {
                                        %>
                                            <input type="text" size="40" name="obligationRuleAttributeId_0" id="obligationRuleAttributeId_0"
                                                   value="<%=currentRuleObligationAttributeId%>" />
                                        <%
                                        } else {
                                        %>
                                            <input type="text" size="40" name="obligationRuleAttributeId_0" id="obligationRuleAttributeId_0" />
                                        <%
                                            }
                                        %>
                                    </td>
                                    <td>
                                        <a onclick="createNewRuleObligationRow();" style="background-image:url(images/add.gif);float:none" type="button"
                                           class="icon-link"></a>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
<%

        if(ruleDTO != null && ruleDTO.getObligationDTOs() != null && ruleDTO.getObligationDTOs().size() > 0){
            List<ObligationDTO> ruleObligationDTOs = ruleDTO.getObligationDTOs();
            ruleObligationDTOs.remove(0);
            for(ObligationDTO dto : ruleObligationDTOs){
                currentRuleObligationType = dto.getType();
                currentRuleObligationId = dto.getObligationId();
                currentRuleObligationAttributeValue = dto.getAttributeValue();
                currentRuleObligationAttributeId = dto.getResultAttributeId();
            %>
                <script type="text/javascript">
                    function createRuleObligationRow() {
                        var rowIndex =  jQuery('#obligationRuleTable tr').last().attr('data-value');
                        var index = parseInt(rowIndex, 10) + 1;
                        jQuery('#obligationRuleTable > tbody:last').append('<tr data-value="'+ index +'">' +
                            '<td style="padding-left:0px !important;padding-right:0px !important"><select id="obligationRuleType_' + index +'" name="obligationRuleType_' + index +'" ><%for (String type : obligationTypes) {if (currentRuleObligationType != null && type.equals(currentRuleObligationType)) {%><option value="<%=type%>" selected="selected"><%=type%></option><%} else {%><option value="<%=type%>"><%=type%></option><%}}%></select></td>' +
                            '<td style="padding-left:0px !important;padding-right:0px !important"><%if (currentRuleObligationId != null && currentRuleObligationId.trim().length() > 0) {%><input type="text" size="20" name="obligationRuleId_' + index +'" id="obligationRuleId_' + index +'" value="<%=currentRuleObligationId%>" /><%} else {%><input type="text" size="20" name="obligationRuleId_' + index +'" id="obligationRuleId_' + index +'" /><%}%></td>'+
                            '<td style="padding-left:0px !important;padding-right:0px !important"><%if (currentRuleObligationAttributeValue != null && currentRuleObligationAttributeValue.trim().length() > 0) {%><input type="text" size="40" name="obligationRuleAttributeValue_' + index +'" id="obligationRuleAttributeValue_' + index +'" value="<%=currentRuleObligationAttributeValue%>" /> <%} else {%><input type="text" size="40" name="obligationRuleAttributeValue_' + index +'" id="obligationRuleAttributeValue_' + index +'"/><%}%></td>'+
                            '<td style="padding-left:0px !important;padding-right:0px !important"><%if (currentRuleObligationAttributeId != null && currentRuleObligationAttributeId.trim().length() > 0) {%><input type="text" size="40" name="obligationRuleAttributeId_' + index +'" id="obligationRuleAttributeId_' + index +'" value="<%=currentRuleObligationAttributeId%>" /><%} else {%><input type="text" size="40" name="obligationRuleAttributeId_' + index +'" id="obligationRuleAttributeId_' + index +'"/><%}%></td>' +
                            '<td><a onclick="removeRow(this)" style="background-image:url(images/delete.gif);" type="button" class="icon-link"></a></td>' +
                            '</tr>');
                    }
                    createRuleObligationRow();
                </script>
            <%
            }
        }

%>
        <tr>
            <td colspan="2" class="buttonRow">
                <%
                    if (ruleDTO != null && ruleDTO.isCompletedRule()) {
                %>
                <input class="button" type="button" value="<fmt:message key='update'/>"
                       onclick="doUpdate();"/>

                <input class="button" type="button" value="<fmt:message key='cancel'/>"
                       onclick="doCancelRule();"/>

                <%
                } else {
                %>

                <input class="button" type="button" value="<fmt:message key='add'/>"
                       onclick="doAdd();"/>
                <%
                    }
                %>
            </td>
        </tr>
        </body>
    </table>
</div>
</tr>

<tr>
    <td colspan="2" style="margin-top:10px;">
    <h2 class="trigger  <%if(ruleDTO == null){%>active<%} %>"><a href="#"><fmt:message
            key="add.new.obligations"/></a></h2>
    <div class="toggle_container" id="newObligationLinkRow">

        <table class="ob-table">
        <td style="width:152px;">Obligation Type</td>
        <td style="width:148px;">Obligation Id</td>
        <td style="width:63px;">Effect </td>
        <td style="width:270px;">Attribute Expression </td>
        <td style="width:150px;">Assignment Id</td>
        </table>
        <table id="obligationTable" name="obligationTable" class="normal"
               style="padding-left:0px !important">
            <tr data-value="0">
                <td style="padding-left:0px !important;padding-right:0px !important">
                    <select id="obligationType_0" name="obligationType_0">
                        <%
                            for (String type : obligationTypes) {
                                if (currentObligationType != null && type.equals(currentObligationType)) {
                        %>
                        <option value="<%=type%>"
                                selected="selected"><%=type%>
                        </option>
                        <%
                        } else {
                        %>
                        <option value="<%=type%>"><%=type%></option>
                        <%
                                }
                            }
                        %>
                    </select>
                </td>

                <td style="padding-left:0px !important;padding-right:0px !important">
                    <%
                        if (currentObligationId != null && currentObligationId.trim().length() > 0) {
                    %>
                        <input type="text" size="20" name="obligationId_0" id="obligationId_0"
                               value="<%=currentObligationId%>" />
                    <%
                    } else {
                    %>
                        <input type="text" size="20" name="obligationId_0" id="obligationId_0" />
                    <%
                        }
                    %>
                </td>

                <td style="padding-left:0px !important;padding-right:0px !important">
                    <select id="obligationEffect_0" name="obligationEffect_0">
                        <%
                            if (ruleEffects != null) {
                                for (String effect : ruleEffects) {
                                    if (effect.equals(currentObligationEffect)) {
                        %>
                        <option value="<%=effect%>" selected="selected"><%=ruleEffect%></option>
                        <%
                        } else {
                        %>
                        <option value="<%=effect%>"><%=effect%></option>
                        <%
                                    }
                                }
                            }
                        %>
                    </select>
                </td>

                <td style="padding-left:0px !important;padding-right:0px !important">
                    <%
                        if (currentObligationAttributeValue != null && currentObligationAttributeValue.trim().length() > 0) {
                    %>
                        <input type="text" size="40" name="obligationAttributeValue_0" id="obligationAttributeValue_0"
                               value="<%=currentObligationAttributeValue%>" />
                    <%
                    } else {
                    %>
                        <input type="text" size="40" name="obligationAttributeValue_0" id="obligationAttributeValue_0" />
                    <%
                        }
                    %>
                </td>
                <td style="padding-left:0px !important;padding-right:0px !important">
                    <%
                        if (currentObligationAttributeId != null && currentObligationAttributeId.trim().length() > 0) {
                    %>
                        <input type="text" size="40" name="obligationAttributeId_0" id="obligationAttributeId_0"
                               value="<%=currentObligationAttributeId%>" />
                    <%
                    } else {
                    %>
                        <input type="text" size="40" name="obligationAttributeId_0" id="obligationAttributeId_0" />
                    <%
                        }
                    %>
                </td>
                <td>
                    <a onclick="createNewObligationRow();" style="background-image:url(images/add.gif);float:none" type="button"
                       class="icon-link"></a>
                </td>
            </tr>
<%
        if(obligationDTOs != null && obligationDTOs.size() > 0){
            obligationDTOs.remove(0);
            for(ObligationDTO dto : obligationDTOs){
                currentObligationType = dto.getType();
                currentObligationId = dto.getObligationId();
                currentObligationEffect = dto.getEffect();
                currentObligationAttributeValue = dto.getAttributeValue();
                currentObligationAttributeId = dto.getResultAttributeId();
            %>
                <script type="text/javascript">
                    function createObligationRow() {
                        var rowIndex =  jQuery('#obligationTable tr').last().attr('data-value');
                        var index = parseInt(rowIndex, 10) + 1;
                        jQuery('#obligationTable > tbody:last').append('<tr>' +
                            '<td style="padding-left:0px !important;padding-right:0px !important"><select id="obligationType_' + index +'" name="obligationType_' + index +'" ><%for (String type : obligationTypes) {if (currentObligationType != null && type.equals(currentObligationType)) {%><option value="<%=type%>" selected="selected"><%=type%></option><%} else {%><option value="<%=type%>"><%=type%></option><%}}%></select></td>' +
                            '<td style="padding-left:0px !important;padding-right:0px !important"><%if (currentObligationId != null && currentObligationId.trim().length() > 0) {%><input type="text" size="20" name="obligationId_' + index +'" id="obligationId_' + index +'" value="<%=currentObligationId%>" /><%} else {%><input type="text" size="20" name="obligationId_' + index +'" id="obligationId_' + index +'" /><%}%></td>'+
                            '<td style="padding-left:0px !important;padding-right:0px !important"><select id="obligationEffect_' + index +'" name="obligationEffect_' + index +'" ><%if (ruleEffects != null) {for (String effect : ruleEffects) {if (effect.equals(currentObligationEffect)) {%><option value="<%=effect%>" selected="selected"><%=ruleEffect%></option><%} else {%><option value="<%=effect%>"><%=effect%></option><%}}}%></select></td>'+
                            '<td style="padding-left:0px !important;padding-right:0px !important"><%if (currentObligationAttributeValue != null && currentObligationAttributeValue.trim().length() > 0) {%><input type="text" size="40" name="obligationAttributeValue_' + index +'" id="obligationAttributeValue_' + index +'" value="<%=currentObligationAttributeValue%>" /> <%} else {%><input type="text" size="40" name="obligationAttributeValue_' + index +'" id="obligationAttributeValue_' + index +'"/><%}%></td>'+
                            '<td style="padding-left:0px !important;padding-right:0px !important"><%if (currentObligationAttributeId != null && currentObligationAttributeId.trim().length() > 0) {%><input type="text" size="40" name="obligationAttributeId_' + index +'" id="obligationAttributeId_' + index +'" value="<%=currentObligationAttributeId%>" /><%} else {%><input type="text" size="40" name="obligationAttributeId_' + index +'" id="obligationAttributeId_' + index +'"/><%}%></td>' +
                            '<td><a onclick="removeRow(this)" style="background-image:url(images/delete.gif);" type="button" class="icon-link"></a></td>' +
                            '</tr>');
                    }
                    createObligationRow();
                </script>
            <%
            }
        }    
%>
        </table>
    </div>
    </td>
</tr>

<tr>
    <td colspan="5">
<div class="heading_A">Defined Rules</div>
    <table id="dataTable" style="width: 100%;margin-top:10px;">
        <thead>
        <tr>
            <th><fmt:message key="rule.id"/></th>
            <th><fmt:message key="rule.effect"/></th>
            <th><fmt:message key="action"/></th>
        </tr>
        </thead>
        <body>
        <%
            if (ruleDTOs != null && ruleDTOs.size() > 0) {
                List<RuleDTO> orderedRuleDTOs = new ArrayList<RuleDTO>();
                String ruleElementOrder = entitlementPolicyBean.getRuleElementOrder();
                if (ruleElementOrder != null) {
                    String[] orderedRuleIds = ruleElementOrder.split(EntitlementPolicyConstants.ATTRIBUTE_SEPARATOR);
                    for (String orderedRuleId : orderedRuleIds) {
                        for (RuleDTO dto : ruleDTOs) {
                            if (orderedRuleId.trim().equals(dto.getRuleId())) {
                                orderedRuleDTOs.add(dto);
                            }
                        }
                    }
                }

                if (orderedRuleDTOs.size() < 1) {
                    orderedRuleDTOs = ruleDTOs;
                }
                for (RuleDTO orderedRuleDTO : orderedRuleDTOs) {
                    if (orderedRuleDTO.isCompletedRule()) {
        %>
        <tr>

            <td>
                <a class="icon-link" onclick="updownthis(this,'up')"
                   style="background-image:url(../admin/images/up-arrow.gif)"></a>
                <a class="icon-link" onclick="updownthis(this,'down')"
                   style="background-image:url(../admin/images/down-arrow.gif)"></a>
                <input type="hidden" value="<%=orderedRuleDTO.getRuleId()%>"/>
                <%=orderedRuleDTO.getRuleId()%>
            </td>
            <td><%=orderedRuleDTO.getRuleEffect()%>
            </td>
            <td>
                <a href="#" onclick="editRule('<%=orderedRuleDTO.getRuleId()%>')"
                   class="icon-link" style="background-image:url(images/edit.gif);"><fmt:message
                        key="edit"/></a>
                <a href="#" onclick="deleteRule('<%=orderedRuleDTO.getRuleId()%>')"
                   class="icon-link" style="background-image:url(images/delete.gif);"><fmt:message
                        key="delete"/></a>
            </td>
        </tr>
        <%
                }
            }
        } else {
        %>
        <tr class="noRuleBox">
            <td colspan="3"><fmt:message key="no.rule.defined"/><br/></td>
        </tr>
        <%
            }
        %>
        </body>
    </table>
    </td>
</tr>

<tr>
    <td class="buttonRow" colspan="2">
        <input type="button" onclick="submitForm();" value="<fmt:message key="finish"/>"
               class="button"/>
        <input type="button" onclick="doCancel();" value="<fmt:message key="cancel" />"
               class="button"/>
    </td>
</tr>
</table>
</form>
</div>
</div>
</fmt:bundle>
