/*
*  Copyright (c) 2005-2010, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
*
*  WSO2 Inc. licenses this file to you under the Apache License,
*  Version 2.0 (the "License"); you may not use this file except
*  in compliance with the License.
*  You may obtain a copy of the License at
*
*    http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing,
* software distributed under the License is distributed on an
* "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
* KIND, either express or implied.  See the License for the
* specific language governing permissions and limitations
* under the License.
*/
package org.wso2.carbon.identity.sso.saml.dto;


public class SAMLSSOServiceProviderDTO {

    private String issuer;
    private String assertionConsumerUrl;
    private String certAlias;
    private String logoutURL;
    private String attributeConsumingServiceIndex;
    private boolean useFullyQualifiedUsername;
    private boolean doSingleLogout;
    private boolean doSignAssertions;
    private boolean doSignResponse;
    private String[] requestedClaims;

    public String getIssuer() {
        return issuer;
    }

    public void setIssuer(String issuer) {
        this.issuer = issuer;
    }

    public String getAssertionConsumerUrl() {
        return assertionConsumerUrl;
    }

    public void setAssertionConsumerUrl(String assertionConsumerUrl) {
        this.assertionConsumerUrl = assertionConsumerUrl;
    }

    public String getCertAlias() {
        return certAlias;
    }

    public void setCertAlias(String certAlias) {
        this.certAlias = certAlias;
    }

    public boolean isUseFullyQualifiedUsername() {
        return useFullyQualifiedUsername;
    }

    public void setUseFullyQualifiedUsername(boolean useFullyQualifiedUsername) {
        this.useFullyQualifiedUsername = useFullyQualifiedUsername;
    }

    public boolean isDoSingleLogout() {
        return doSingleLogout;
    }

    public void setDoSingleLogout(boolean doSingleLogout) {
        this.doSingleLogout = doSingleLogout;
    }

    public String getLogoutURL() {
        return logoutURL;
    }

    public void setLogoutURL(String logoutURL) {
        this.logoutURL = logoutURL;
    }

    /**
     * 
     * @return
     */
    public boolean isDoSignAssertions() {
        return doSignAssertions;
    }

    /**
     * 
     * @param doSignAssertions
     */
    public void setDoSignAssertions(boolean doSignAssertions) {
        this.doSignAssertions = doSignAssertions;
    }

	public String getAttributeConsumingServiceIndex() {
	    return attributeConsumingServiceIndex;
    }

	public void setAttributeConsumingServiceIndex(String attributeConsumingServiceIndex) {
	    this.attributeConsumingServiceIndex = attributeConsumingServiceIndex;
    }

	/**
     * @return the requestedClaims
     */
    public String[] getRequestedClaims() {
	    return requestedClaims;
    }

	/**
     * @param requestedClaims the requestedClaims to set
     */
    public void setRequestedClaims(String[] requestedClaims) {
	    this.requestedClaims = requestedClaims;
    }

	/**
     * @return the doSignResponse
     */
    public boolean isDoSignResponse() {
	    return doSignResponse;
    }

	/**
     * @param doSignResponse the doSignResponse to set
     */
    public void setDoSignResponse(boolean doSignResponse) {
	    this.doSignResponse = doSignResponse;
    }

}

