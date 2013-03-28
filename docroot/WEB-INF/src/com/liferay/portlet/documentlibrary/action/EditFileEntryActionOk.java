/**
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */
package com.liferay.portlet.documentlibrary.action;

import com.liferay.portal.kernel.servlet.SessionErrors;
import com.liferay.portal.kernel.struts.BaseStrutsPortletAction;
import com.liferay.portal.kernel.struts.StrutsPortletAction;
import com.liferay.portal.kernel.util.Constants;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portlet.documentlibrary.antivirus.AntivirusScannerException;

import javax.portlet.ActionRequest;
import javax.portlet.ActionResponse;
import javax.portlet.PortletConfig;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;
import javax.portlet.ResourceRequest;
import javax.portlet.ResourceResponse;

/**
 * @author Sergio González
 */
public class EditFileEntryActionOk extends BaseStrutsPortletAction {

	public void processAction(StrutsPortletAction originalStrutsPortletAction, PortletConfig portletConfig,
			ActionRequest actionRequest, ActionResponse actionResponse) throws Exception {

		try {
			String cmd = ParamUtil.getString(actionRequest, Constants.CMD);
			
			String imageData = ParamUtil.getString(actionRequest, "imageData");
			String fileEntryId = ParamUtil.getString(actionRequest, "fileEntryId");
			
			if (cmd.equals(Constants.CHECKOUT)){
				System.out.println("updating");
			}
			
			originalStrutsPortletAction.processAction(originalStrutsPortletAction, portletConfig, actionRequest, actionResponse);
		} catch (AntivirusScannerException ase) {
			SessionErrors.add(actionRequest, ase.getClass());
		}
	}

	public String render(StrutsPortletAction originalStrutsPortletAction, PortletConfig portletConfig,
			RenderRequest renderRequest, RenderResponse renderResponse) throws Exception {

		return originalStrutsPortletAction.render(null, portletConfig, renderRequest, renderResponse);
	}

	public void serveResource(StrutsPortletAction originalStrutsPortletAction, PortletConfig portletConfig,
			ResourceRequest resourceRequest, ResourceResponse resourceResponse) throws Exception {

		originalStrutsPortletAction.serveResource(originalStrutsPortletAction, portletConfig, resourceRequest,
				resourceResponse);
	}
}