/**
 * Copyright (c) 2000-2012 Liferay, Inc. All rights reserved.
 *
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

package com.liferay.portlet.documentlibrary.util;

import com.liferay.portal.kernel.audit.AuditMessage;
import com.liferay.portal.kernel.audit.AuditRequestThreadLocal;
import com.liferay.portal.kernel.json.JSONArray;
import com.liferay.portal.kernel.json.JSONFactoryUtil;
import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.kernel.util.GetterUtil;
import com.liferay.portal.kernel.util.StringPool;
import com.liferay.portal.security.auth.CompanyThreadLocal;
import com.liferay.portal.security.auth.PrincipalThreadLocal;
import com.liferay.portal.util.PortalUtil;

import java.util.List;

/**
 * @author Mika Koivisto
 * @author Brian Wing Shun Chan
 */
public class AuditMessageBuilder {

	public static AuditMessage buildAuditMessage(
		String eventType, String className, long classPK,
		List<Attribute> attributes) {

		long companyId = CompanyThreadLocal.getCompanyId();

		long userId = 0;

		if (PrincipalThreadLocal.getName() != null) {
			userId = GetterUtil.getLong(PrincipalThreadLocal.getName());
		}

		AuditRequestThreadLocal auditRequestThreadLocal =
			AuditRequestThreadLocal.getAuditThreadLocal();

		long realUserId = auditRequestThreadLocal.getRealUserId();
		String realUserName = PortalUtil.getUserName(
			realUserId, StringPool.BLANK);

		JSONObject additionalInfo = JSONFactoryUtil.createJSONObject();

		if ((realUserId > 0) && (userId != realUserId)) {
			additionalInfo.put("doAsUserId", String.valueOf(userId));
			additionalInfo.put(
				"doAsUserName",
				PortalUtil.getUserName(userId, StringPool.BLANK));
		}

		if (attributes != null) {
			additionalInfo.put("attributes", _getAttributesJSON(attributes));
		}

		return new AuditMessage(
			eventType, companyId, realUserId, realUserName, className,
			String.valueOf(classPK), null, additionalInfo);
	}

	private static JSONArray _getAttributesJSON(List<Attribute> attributes) {
		JSONArray jsonArray = JSONFactoryUtil.createJSONArray();

		for (Attribute attribute : attributes) {
			JSONObject attributeJSONObject = JSONFactoryUtil.createJSONObject();

			attributeJSONObject.put("name", attribute.getName());
			attributeJSONObject.put("newValue", attribute.getNewValue());
			attributeJSONObject.put("oldValue", attribute.getOldValue());

			jsonArray.put(attributeJSONObject);
		}

		return jsonArray;
	}

}