package org.wso2.carbon.appfactory.governance.lifecycle;

import org.apache.axiom.om.OMElement;
import org.apache.axiom.om.impl.builder.StAXOMBuilder;
import org.apache.axis2.AxisFault;
import org.apache.axis2.addressing.EndpointReference;
import org.apache.axis2.client.ServiceClient;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.wso2.carbon.appfactory.common.AppFactoryConfiguration;
import org.wso2.carbon.appfactory.common.AppFactoryConstants;
import org.wso2.carbon.appfactory.svn.repository.mgt.util.Util;
import org.wso2.carbon.governance.registry.extensions.executors.ServiceVersionExecutor;
import org.wso2.carbon.governance.registry.extensions.executors.utils.ExecutorConstants;
import org.wso2.carbon.governance.registry.extensions.interfaces.Execution;
import org.wso2.carbon.registry.core.Resource;
import org.wso2.carbon.registry.core.ResourcePath;
import org.wso2.carbon.registry.core.exceptions.RegistryException;
import org.wso2.carbon.registry.core.jdbc.handlers.RequestContext;
import org.wso2.carbon.utils.CarbonUtils;

import javax.xml.stream.XMLStreamException;
import java.io.ByteArrayInputStream;
import java.util.HashMap;
import java.util.Map;

import static org.wso2.carbon.governance.registry.extensions.executors.utils.Utils.addNewId;
import static org.wso2.carbon.governance.registry.extensions.executors.utils.Utils.populateParameterMap;


public class AppFactoryLCExecutor implements Execution {

    private static final Log log = LogFactory.getLog(ServiceVersionExecutor.class);
    private static final String KEY = ExecutorConstants.RESOURCE_VERSION;
    private Map parameterMap;

    public void init(Map map) {
        parameterMap = map;
    }

    public boolean execute(RequestContext requestContext, String currentState, String targetState) {

        String resourcePath = requestContext.getResource().getPath();
        String newPath;

        //        Now we are going to get the list of parameters from the context and add it to a map
        Map<String, String> currentParameterMap = new HashMap<String, String>();

        //        Here we are populating the parameter map that was given from the UI
        if (!populateParameterMap(requestContext, currentParameterMap)) {
            log.error("Failed to populate the parameter map");
            return false;
        }

        final String applicationId = currentParameterMap.get("applicationId");
        final String revision = currentParameterMap.get("revision");
        final String targetVersion = currentParameterMap.get("version");
        final String stage = currentParameterMap.get("stage");
        final String build = currentParameterMap.get("build");

//        This section is there to add a targetVersion to the path if needed.
//        This is all based on the lifecycle configuration and the configuration should be as follows.
//        path = /_system/governance/environment/{@targetVersion}
//        Also for this the user has to have a transition UI where he can give the targetVersion
        String currentEnvironment = getReformattedPath((String) parameterMap.get(ExecutorConstants.CURRENT_ENVIRONMENT),
                                                       KEY, currentParameterMap.get(resourcePath));
        String targetEnvironment = getReformattedPath((String) parameterMap.get(ExecutorConstants.TARGET_ENVIRONMENT),
                                                      KEY, currentParameterMap.get(resourcePath));

        if (resourcePath.startsWith(currentEnvironment)) {

            newPath = resourcePath.substring(currentEnvironment.length());

            // 1st element is "", 2st element is app name , 3rd element is $Stage , 4th element $Version, 5th element is appinfo
            String newPathArray[] = newPath.split("/");
            String appName = newPathArray[1];
            String currentVersion = newPathArray[3];
            //String targetVersion = "1.0.0";

            // if the app is trunk then we need targetVersion.
            if ("trunk".equals(newPathArray[3])) {

                // Append targetVersion from here
                if (targetVersion != null) {
                    newPath = "/" + appName + "/" + targetState + "/" + targetVersion + "/" + newPathArray[4];
                } else {
                    log.error("Can not find application targetVersion. " +
                              "Application targetVersion is required to perform lifecycle operation");
                    return false;
                }
            } else {
                // Application is not a trunk targetVersion. So it can have targetVersion with it or user can define targetVersion
                if (targetVersion != null) {
                    newPath = "/" + appName + "/" + targetState + "/" + targetVersion + "/" + newPathArray[4];

                } else {
                    newPath = "/" + appName + "/" + targetState + "/" + newPathArray[3] + "/" + newPathArray[4];
                }

            }


            newPath = targetEnvironment + newPath;
            if ("Development".equals(currentState)) {
                branchRepositoryOnNewAppVersion(applicationId, revision, currentVersion, targetVersion);
            } else if ("Production".equals(targetState)) {
                tagRepositoryOnNewAppVersion(applicationId, revision, currentVersion, targetVersion);
            }
        } else {
            log.warn("Resource is not in the given environment");
            return true;
        }

        try {
            requestContext.getRegistry().copy(resourcePath, newPath);
            Resource newResource = requestContext.getRegistry().get(newPath);

            if (newResource.getUUID() != null) {
                addNewId(requestContext.getRegistry(), newResource, newPath);
            }

            requestContext.setResource(newResource);
            requestContext.setResourcePath(new ResourcePath(newPath));


            // Executing the bpel
            executeBPEL(applicationId, revision, targetVersion, stage, build);

            return true;
        } catch (RegistryException e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
            return false;
        }

    }

    public String getReformattedPath(String originalPath, String key, String value) {
        if (key == null || value == null) {
            return originalPath;
        }
        return originalPath.replace(key, value);
    }


    //private void executeBPEL(final String applicationId, final String version, final String revision) {
    private void executeBPEL(final String applicationId, final String revision,
                             final String version, final String stage, final String build) {


        AppFactoryConfiguration configuration = Util.getConfiguration();
        final String EPR = configuration.getFirstProperty(AppFactoryConstants.ENDPOINT_DEPLOY_TO_STAGE);
        //final String EPR = "https://10.100.2.101:9443/services/echo";

        new Thread(new Runnable() {
            public void run() {
                try {
                    Thread.sleep(5000);
                } catch (InterruptedException ignored) {
                }
                try {
                    //Create a service client
                    ServiceClient client = new ServiceClient();

                    //Set the endpoint address
                    client.getOptions().setTo(new EndpointReference(EPR));
                    client.getOptions().setAction("echoInt");


                    //Make the request and get the response
                    //client.sendRobust(getPayload(applicationId, revision, version, stage, build));
                    client.fireAndForget(getPayload(applicationId, revision, version, stage, build));
                } catch (AxisFault e) {
                    log.error(e);
                    e.printStackTrace();
                } catch (XMLStreamException e) {
                    log.error(e);
                }
            }
        }).start();
    }

    private static OMElement getPayload(
            final String applicationId, final String revision, final String version,
            final String stage,
            final String build) throws XMLStreamException, javax.xml.stream.XMLStreamException {


        String payload = "   <p:DeployToStageRequest xmlns:p=\"http://wso2.org\">\n" +
                         "      <applicationId xmlns=\"http://wso2.org\">" + applicationId + "</applicationId>\n" +
                         "      <revision xmlns=\"http://wso2.org\">" + revision + "</revision>\n" +
                         "      <version xmlns=\"http://wso2.org\">" + version + "</version>\n" +
                         "      <stage xmlns=\"http://wso2.org\">" + stage + "</stage>\n" +
                         "      <build xmlns=\"http://wso2.org\">" + build + "</build>\n" +
                         "   </p:DeployToStageRequest>";


        return new StAXOMBuilder(new ByteArrayInputStream(payload.getBytes())).getDocumentElement();
    }

    private static boolean branchRepositoryOnNewAppVersion(String applicationId, String revision,
                                                           String currentVersion,
                                                           String targetVersion) {

        AppFactoryConfiguration configuration = Util.getConfiguration();
        final String EPR = configuration.getFirstProperty(AppFactoryConstants.REVISION_CONTROLLER_SERVICE_EPR);
        final String currentVersionFinal = currentVersion;
        final String targetVersionFinal = targetVersion;
        final String revisionFinal = revision;
        final String appId = applicationId;
        new Thread(new Runnable() {
            public void run() {

                try {
                    //Create a service client
                    ServiceClient client = new ServiceClient();

                    //Set the endpoint address
                    client.getOptions().setTo(new EndpointReference(EPR));
                    client.getOptions().setAction("branch");
                    AppFactoryConfiguration configuration = Util.getConfiguration();
                    String username = configuration.getFirstProperty(AppFactoryConstants.SERVER_ADMIN_NAME);
                    String password = configuration.getFirstProperty(AppFactoryConstants.SERVER_ADMIN_PASSWORD);

                    CarbonUtils.setBasicAccessSecurityHeaders(username, password, client);

                    //Make the request and get the response
                    String payload = "<p:branch xmlns:p=\"http://services.core.appfactory.carbon.wso2.org\">\n" +
                                     "      <xs:appId xmlns:xs=\"http://services.core.appfactory.carbon.wso2.org\">" + appId + "</xs:appId>\n" +
                                     "      <xs:currentVersion xmlns:xs=\"http://services.core.appfactory.carbon.wso2.org\">" + currentVersionFinal + "</xs:currentVersion>\n" +
                                     "      <xs:targetVersion xmlns:xs=\"http://services.core.appfactory.carbon.wso2.org\">" + targetVersionFinal + "</xs:targetVersion>\n" +
                                     "      <xs:currentRevision xmlns:xs=\"http://services.core.appfactory.carbon.wso2.org\">" + revisionFinal + "</xs:currentRevision>\n" +
                                     "   </p:branch>";
                    client.fireAndForget(new StAXOMBuilder(new ByteArrayInputStream(payload.getBytes())).getDocumentElement());
                } catch (AxisFault e) {
                    log.error(e);
                    e.printStackTrace();
                } catch (XMLStreamException e) {
                    log.error(e);
                }
            }
        }).start();
        return true;
    }

    private static boolean tagRepositoryOnNewAppVersion(String applicationId, String revision,
                                                        String currentVersion,
                                                        String targetVersion) {

        AppFactoryConfiguration configuration = Util.getConfiguration();
        final String EPR = configuration.getFirstProperty(AppFactoryConstants.REVISION_CONTROLLER_SERVICE_EPR);
        final String currentVersionFinal = currentVersion;
        final String targetVersionFinal = targetVersion;
        final String revisionFinal = revision;
        final String appId = applicationId;
        new Thread(new Runnable() {
            public void run() {
                try {
                    Thread.sleep(5000);
                } catch (InterruptedException ignored) {
                }
                try {
                    //Create a service client
                    ServiceClient client = new ServiceClient();

                    //Set the endpoint address
                    client.getOptions().setTo(new EndpointReference(EPR));
                    client.getOptions().setAction("tag");
                    AppFactoryConfiguration configuration = Util.getConfiguration();
                    String username = configuration.getFirstProperty(AppFactoryConstants.SERVER_ADMIN_NAME);
                    String password = configuration.getFirstProperty(AppFactoryConstants.SERVER_ADMIN_PASSWORD);

                    CarbonUtils.setBasicAccessSecurityHeaders(username, password, client);

                    //Make the request and get the response
                    String payload = "<p:tag xmlns:p=\"http://services.core.appfactory.carbon.wso2.org\">\n" +
                                     "      <xs:appId xmlns:xs=\"http://services.core.appfactory.carbon.wso2.org\">" + appId + "</xs:appId>\n" +
                                     "      <xs:currentVersion xmlns:xs=\"http://services.core.appfactory.carbon.wso2.org\">" + currentVersionFinal + "</xs:currentVersion>\n" +
                                     "      <xs:targetVersion xmlns:xs=\"http://services.core.appfactory.carbon.wso2.org\">" + targetVersionFinal + "</xs:targetVersion>\n" +
                                     "      <xs:currentRevision xmlns:xs=\"http://services.core.appfactory.carbon.wso2.org\">" + revisionFinal + "</xs:currentRevision>\n" +
                                     "   </p:tag>";
                    client.sendReceive(new StAXOMBuilder(new ByteArrayInputStream(payload.getBytes())).getDocumentElement());
                } catch (AxisFault e) {
                    log.error(e);
                    e.printStackTrace();
                } catch (XMLStreamException e) {
                    log.error(e);
                }
            }
        }).start();
        return true;
    }
}
