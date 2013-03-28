package com.liferay.portlet.documentlibrary.listener;

import java.util.List;

import com.liferay.portal.ModelListenerException;
import com.liferay.portal.kernel.audit.AuditMessage;
import com.liferay.portal.kernel.audit.AuditRouterUtil;
import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.model.BaseModelListener;
import com.liferay.portlet.documentlibrary.model.DLFileEntry;
import com.liferay.portlet.documentlibrary.service.DLFileEntryLocalServiceUtil;
import com.liferay.portlet.documentlibrary.util.Attribute;
import com.liferay.portlet.documentlibrary.util.AttributesBuilder;
import com.liferay.portlet.documentlibrary.util.AuditMessageBuilder;
import com.liferay.portlet.documentlibrary.util.EventTypes;



public class DLFileEntryListener extends BaseModelListener<DLFileEntry> {

	public void onBeforeCreate(DLFileEntry dlFileEntry) throws ModelListenerException {
		auditOnCreateOrRemove(EventTypes.ADD, dlFileEntry);
	}

	public void onBeforeRemove(DLFileEntry dlFileEntry) throws ModelListenerException {
		auditOnCreateOrRemove(EventTypes.DELETE, dlFileEntry);
	}

	public void onBeforeUpdate(DLFileEntry newDLFileEntry) throws ModelListenerException {
		try {
			DLFileEntry oldDLFileEntry = DLFileEntryLocalServiceUtil.getDLFileEntry(newDLFileEntry.getFileEntryId());

			List<Attribute> attributes = getModifiedAttributes(newDLFileEntry, oldDLFileEntry);

			if (!attributes.isEmpty()) {
				AuditMessage auditMessage = AuditMessageBuilder.buildAuditMessage(EventTypes.UPDATE,
						DLFileEntry.class.getName(), newDLFileEntry.getFileEntryId(), attributes);

				AuditRouterUtil.route(auditMessage);
			}
		} catch (Exception e) {
			throw new ModelListenerException(e);
		}
	}

	protected void auditOnCreateOrRemove(String eventType, DLFileEntry dlFileEntry) throws ModelListenerException {

		try {
			AuditMessage auditMessage = AuditMessageBuilder.buildAuditMessage(eventType, DLFileEntry.class.getName(),
					dlFileEntry.getFileEntryId(), null);

			JSONObject additionalInfo = auditMessage.getAdditionalInfo();
			additionalInfo.put("title", dlFileEntry.getTitle());
			additionalInfo.put("description", dlFileEntry.getDescription());
			additionalInfo.put("mimeType", dlFileEntry.getMimeType());
			additionalInfo.put("fileEntryTypeId", dlFileEntry.getFileEntryTypeId());
			AuditRouterUtil.route(auditMessage);
		} catch (Exception e) {
			throw new ModelListenerException(e);
		}
	}

	protected List<Attribute> getModifiedAttributes(DLFileEntry newDLFileEntry, DLFileEntry oldDLFileEntry) {

		AttributesBuilder attributesBuilder = new AttributesBuilder(newDLFileEntry, oldDLFileEntry);
		attributesBuilder.add("title");
		attributesBuilder.add("description");
		attributesBuilder.add("mimeType");
		attributesBuilder.add("fileEntryTypeId");
		List<Attribute> attributes = attributesBuilder.getAttributes();

		return attributes;
	}
}