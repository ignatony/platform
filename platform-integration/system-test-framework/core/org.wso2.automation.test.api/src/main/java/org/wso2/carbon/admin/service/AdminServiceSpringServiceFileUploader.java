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

import org.apache.axis2.AxisFault;
import org.apache.axis2.context.ConfigurationContext;
import org.apache.axis2.context.ConfigurationContextFactory;
import org.apache.axis2.engine.AxisConfiguration;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.wso2.carbon.CarbonConstants;
import org.wso2.carbon.admin.service.utils.AuthenticateStub;
import org.wso2.carbon.springservices.stub.ExceptionException;
import org.wso2.carbon.springservices.stub.ServiceUploaderStub;
import org.wso2.carbon.springservices.stub.aarservices.xsd.AARServiceData;
import org.wso2.carbon.springservices.ui.SpringServiceMaker;
import org.wso2.carbon.springservices.ui.SpringBeansData;
import org.wso2.carbon.ui.CarbonUIMessage;

import javax.activation.DataHandler;
import java.io.File;
import java.rmi.RemoteException;
import java.util.UUID;


public class AdminServiceSpringServiceFileUploader {
    private static final Log log = LogFactory.getLog(AdminServiceSpringServiceFileUploader.class);

    private ServiceUploaderStub serviceUploaderStub;

    public AdminServiceSpringServiceFileUploader(String backEndUrl) throws AxisFault {
        String serviceName = "ServiceUploader";
        String endPoint = backEndUrl + serviceName;
        serviceUploaderStub = new ServiceUploaderStub(endPoint);
    }

    public void uploadSpringServiceFile(String sessionCookie, String fileName, DataHandler dh)
            throws ExceptionException, RemoteException {
        AARServiceData aarServiceData;
        AuthenticateStub.authenticateStub(sessionCookie, serviceUploaderStub);
        aarServiceData = new AARServiceData();
        aarServiceData.setFileName(fileName);
        aarServiceData.setDataHandler(dh);
        aarServiceData.setServiceHierarchy("");

        serviceUploaderStub.uploadService(new AARServiceData[]{aarServiceData});
        log.info("Spring Artifact Uploaded");
    }
}
