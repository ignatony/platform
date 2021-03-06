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
package org.wso2.automation.common.test.greg.metadatasearch;

import org.testng.Assert;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;
import org.wso2.automation.common.test.greg.metadatasearch.bean.SearchParameterBean;
import org.wso2.carbon.admin.service.RegistrySearchAdminService;
import org.wso2.carbon.authenticator.stub.LoginAuthenticationExceptionException;
import org.wso2.carbon.registry.core.Resource;
import org.wso2.carbon.registry.core.exceptions.RegistryException;
import org.wso2.carbon.registry.search.stub.SearchAdminServiceRegistryExceptionException;
import org.wso2.carbon.registry.search.stub.beans.xsd.AdvancedSearchResultsBean;
import org.wso2.carbon.registry.search.stub.beans.xsd.ArrayOfString;
import org.wso2.carbon.registry.search.stub.beans.xsd.CustomSearchParameterBean;
import org.wso2.carbon.registry.search.stub.common.xsd.ResourceData;
import org.wso2.carbon.registry.ws.client.registry.WSRegistryServiceClient;
import org.wso2.platform.test.core.ProductConstant;
import org.wso2.platform.test.core.utils.UserListCsvReader;
import org.wso2.platform.test.core.utils.environmentutils.EnvironmentBuilder;
import org.wso2.platform.test.core.utils.environmentutils.EnvironmentVariables;
import org.wso2.platform.test.core.utils.gregutils.RegistryProvider;

import java.rmi.RemoteException;

/*
Search Registry metadata by last updater Name
*/
public class RegistrySearchByUpdater {

    private String sessionCookie;
    private String userName;

    private RegistrySearchAdminService searchAdminService;
    private WSRegistryServiceClient registry;

    @BeforeClass
    public void init()
            throws LoginAuthenticationExceptionException, RemoteException, RegistryException {
        EnvironmentBuilder builder = new EnvironmentBuilder().greg(3);
        EnvironmentVariables gregServer = builder.build().getGreg();
        userName = UserListCsvReader.getUserInfo(3).getUserName();
        sessionCookie = gregServer.getSessionCookie();
        searchAdminService = new RegistrySearchAdminService(gregServer.getBackEndUrl());
        registry = new RegistryProvider().getRegistry(3, ProductConstant.GREG_SERVER_NAME);

    }

    @Test(priority = 1, groups = {"wso2.greg"}, description = "Metadata search by available Updater Name")
    public void searchResourceByUpdater()
            throws SearchAdminServiceRegistryExceptionException, RemoteException,
                   RegistryException {
        CustomSearchParameterBean searchQuery = new CustomSearchParameterBean();
        SearchParameterBean paramBean = new SearchParameterBean();
        paramBean.setUpdater(userName);
        ArrayOfString[] paramList = paramBean.getParameterList();

        searchQuery.setParameterValues(paramList);
        AdvancedSearchResultsBean result = searchAdminService.getAdvancedSearchResults(sessionCookie, searchQuery);
        Assert.assertNotNull(result.getResourceDataList(), "No Record Found");
        Assert.assertTrue((result.getResourceDataList().length > 0), "No Record Found. set valid updater name");
        for (ResourceData resource : result.getResourceDataList()) {
            Assert.assertTrue(registry.get(resource.getResourcePath()).getLastUpdaterUserName().contains(userName),
                              "search word not contain on Updater Name :" + resource.getResourcePath());
        }


    }

    @Test(priority = 2, groups = {"wso2.greg"}, description = "Metadata search by available Updater Name not")
    public void searchResourceByUpdaterNot()
            throws SearchAdminServiceRegistryExceptionException, RemoteException,
                   RegistryException {
        CustomSearchParameterBean searchQuery = new CustomSearchParameterBean();
        SearchParameterBean paramBean = new SearchParameterBean();
        paramBean.setUpdater(userName);
        ArrayOfString[] paramList = paramBean.getParameterList();

        searchQuery.setParameterValues(paramList);

        // to set updatedRangeNegate
        ArrayOfString updaterNameNegate = new ArrayOfString();
        updaterNameNegate.setArray(new String[]{"updaterNameNegate", "on"});

        searchQuery.addParameterValues(updaterNameNegate);

        AdvancedSearchResultsBean result = searchAdminService.getAdvancedSearchResults(sessionCookie, searchQuery);
        Assert.assertNotNull(result.getResourceDataList(), "No Record Found");
        Assert.assertTrue((result.getResourceDataList().length > 0), "No Record Found. set valid Updater name");
        for (ResourceData resource : result.getResourceDataList()) {
            Assert.assertFalse(registry.get(resource.getResourcePath()).getLastUpdaterUserName().contains(userName),
                               "search word contain on Updater Name :" + resource.getResourcePath());
        }


    }

//    @Test(priority = 3, groups = {"wso2.greg"}, description = "Metadata search by Updater Name pattern matching")
    public void searchResourceByUpdaterNamePattern()
            throws SearchAdminServiceRegistryExceptionException, RemoteException,
                   RegistryException {
        CustomSearchParameterBean searchQuery = new CustomSearchParameterBean();
        SearchParameterBean paramBean = new SearchParameterBean();
        paramBean.setUpdater("wso2%user");
        ArrayOfString[] paramList = paramBean.getParameterList();

        searchQuery.setParameterValues(paramList);
        AdvancedSearchResultsBean result = searchAdminService.getAdvancedSearchResults(sessionCookie, searchQuery);
        Assert.assertNotNull(result.getResourceDataList(), "No Record Found");
        Assert.assertTrue((result.getResourceDataList().length > 0), "No Record Found. set valid Updater name pattern");
        for (ResourceData resourceData : result.getResourceDataList()) {
            Resource resource = registry.get(resourceData.getResourcePath());
            Assert.assertTrue((resource.getLastUpdaterUserName().contains("wso2")
                               && resource.getLastUpdaterUserName().contains("user")),
                              "search word pattern not contain on Updater Name :" + resourceData.getResourcePath());
        }

    }


    @Test(priority = 4, groups = {"wso2.greg"}, description = "Metadata search by unavailable Updater Name")
    public void searchResourceByUnAvailableUpdaterName()
            throws SearchAdminServiceRegistryExceptionException, RemoteException {
        CustomSearchParameterBean searchQuery = new CustomSearchParameterBean();
        SearchParameterBean paramBean = new SearchParameterBean();
        paramBean.setUpdater("xyz1234");
        ArrayOfString[] paramList = paramBean.getParameterList();

        searchQuery.setParameterValues(paramList);
        AdvancedSearchResultsBean result = searchAdminService.getAdvancedSearchResults(sessionCookie, searchQuery);
        Assert.assertNull(result.getResourceDataList(), "Result Object found");


    }

//    @Test(priority = 5, dataProvider = "invalidCharacter", groups = {"wso2.greg"},
//          description = "Metadata search by Updater Name with invalid characters")
    public void searchResourceByUpdaterNameWithInvalidCharacter(String invalidInput)
            throws SearchAdminServiceRegistryExceptionException, RemoteException {
        CustomSearchParameterBean searchQuery = new CustomSearchParameterBean();
        SearchParameterBean paramBean = new SearchParameterBean();

        paramBean.setUpdater(invalidInput);
        ArrayOfString[] paramList = paramBean.getParameterList();
        searchQuery.setParameterValues(paramList);
        AdvancedSearchResultsBean result = searchAdminService.getAdvancedSearchResults(sessionCookie, searchQuery);
        Assert.assertNull(result.getResourceDataList(), "Result Object found.");


    }

    @DataProvider(name = "invalidCharacter")
    public Object[][] invalidCharacter() {
        return new Object[][]{
                {"<"},
                {">"},
                {"#"},
                {"   "},
                {""},
                {"@"},
                {"|"},
                {"^"},
                {"/"},
                {"\\"},
                {","},
                {"\""},
                {"~"},
                {"!"},
                {"*"},
                {"{"},
                {"}"},
                {"["},
                {"]"},
                {"-"},
                {"("},
                {")"}
        };


    }
}
