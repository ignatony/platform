/*
*Copyright (c) 2005-2010, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
*
*WSO2 Inc. licenses this file to you under the Apache License,
*Version 2.0 (the "License"); you may not use this file except
*in compliance with the License.
*You may obtain a copy of the License at
*
*http://www.apache.org/licenses/LICENSE-2.0
*
*Unless required by applicable law or agreed to in writing,
*software distributed under the License is distributed on an
*"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
*KIND, either express or implied.  See the License for the
*specific language governing permissions and limitations
*under the License.
*/

package org.wso2.carbon.admin.service;

import org.apache.axiom.om.OMElement;
import org.apache.axiom.om.impl.builder.StAXOMBuilder;
import org.apache.axis2.AxisFault;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.wso2.carbon.admin.service.utils.AuthenticateStub;
import org.wso2.carbon.priority.executors.stub.PriorityMediationAdminStub;

import javax.activation.DataHandler;
import javax.xml.stream.XMLInputFactory;
import javax.xml.stream.XMLStreamException;
import javax.xml.stream.XMLStreamReader;
import java.io.IOException;

public class AdminServiceMediationyExecuterAdmin {
    String backendUrl = null;
    String SessionCookie = null;
    PriorityMediationAdminStub priorityMediationAdmin;
    private static final Log log = LogFactory.getLog(AdminServiceMediationyExecuterAdmin.class);

    public AdminServiceMediationyExecuterAdmin(String backendUrl, String sessionCookie) {
        this.backendUrl = backendUrl;
        this.SessionCookie = sessionCookie;
    }

    private PriorityMediationAdminStub setPriorityExecutorStub() throws AxisFault {
        final String priorityAdminServiceUrl = backendUrl + "PriorityMediationAdmin";
        PriorityMediationAdminStub priorityMediator = null;
        priorityMediator = new PriorityMediationAdminStub(priorityAdminServiceUrl);
        AuthenticateStub.authenticateStub(SessionCookie, priorityMediator);
        return priorityMediator;
    }

    public void addPriorityMediator(String name,DataHandler dh)
            throws IOException, XMLStreamException {
        priorityMediationAdmin = this.setPriorityExecutorStub();
        XMLStreamReader parser =
                XMLInputFactory.newInstance().createXMLStreamReader(dh.getInputStream());
        StAXOMBuilder builder = new StAXOMBuilder(parser);
        OMElement messageProcessorElem = builder.getDocumentElement();
        priorityMediationAdmin.add(name,messageProcessorElem);
    }
}
