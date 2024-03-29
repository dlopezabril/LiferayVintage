<%@ include file="/html/portlet/document_library/init.jsp" %>


<portlet:defineObjects />

<portlet:renderURL var="renderActualURL"/>

<portlet:resourceURL var="requestUrl"></portlet:resourceURL>


<%-- js libraries - jquery and slider --%>
<script type="text/javascript" src="/html/js/vintage/jquery-1.9.1.min.js"></script>
<script type="text/javascript" src="/html/js/vintage/jquery-ui.js"></script>
<%-- js libraries - save screen image --%>
<script type="text/javascript" src="/html/js/vintage/base64.js"></script>
<script type="text/javascript" src="/html/js/vintage/canvas2image.js"></script>
<%-- js libraries - vintage effects --%>
<script type="text/javascript" src="/html/js/vintage/vintage.js"></script>
<script type="text/javascript" src="/html/js/vintage/vintageliferay.js"></script>
<%-- DWR AJAX setup --%>
<script type='text/javascript' src='<%=renderActualURL%>/dwr/engine.js'></script>
<script type='text/javascript' src='<%=renderActualURL%>/dwr/util.js'></script>
<script type='text/javascript' src='<%=renderActualURL%>/dwr/interface/dwrService.js'></script>




<script type="text/javascript">
$(document).ready(
		
	function() {
		
	   	$('input[name=filterConfigurationType]:radio').click(function(event){
	   		if($(this).val() == "preset"){
	   			$('.columnFilterPreset').css('visibility', 'visible');
	   			$('.columnFilterEdit').css('visibility', 'hidden');
	   		}else{
	   			$('.columnFilterPreset').css('visibility', 'hidden');
	   			$('.columnFilterEdit').css('visibility', 'visible');
	   		}
	   	});
		
		$("#filterImageBotton").click(function() {
			//saveCanvas($("img.lfr-preview-file-image-current"), "JPEG");
			//window.open($("img.lfr-preview-file-image-current").prop('src'), "toDataURL() image", "width=600, height=200");
		});

		$("#saveImageBotton").click(function() {
			var url = '<%=renderActualURL%>';
			var requestUrl = '<%=requestUrl%>';
			var imageData = $("img.lfr-preview-file-image-current").prop('src').replace('data:image/jpeg;base64,', '');
			alert(imageData);
			alert(requestUrl);
			
			var param ="&imageData=" + imageData;
			
			$.ajax({
				type:"GET",
				url:requestUrl,
				cache:false,
				async:false,
				data:param,
				success: function(data){
					<!-- TODO if success-->
				}
			});   
			
			<%
			/*
			PortletURL viewFileEntryURL = renderResponse.createRenderURL();
			viewFileEntryURL.setParameter("struts_action", "/document_library/view_file_entry");
			viewFileEntryURL.setParameter("redirect", currentURL);
			viewFileEntryURL.setParameter("fileEntryId", String.valueOf(fileEntry.getFileEntryId()));
			viewFileEntryURL.setParameter("imageData", "/my_sites/view");
			
			renderResponse.createRenderURL();
			*/
			%>
			
			alert(imageData);
			//viewFileEntryURL.setParameter("imageData", "");

		});
		
	});
	
</script>



<%
String tabs2 = ParamUtil.getString(request, "tabs2", "version-history");

String redirect = ParamUtil.getString(request, "redirect");

String referringPortletResource = ParamUtil.getString(request, "referringPortletResource");

String uploadProgressId = "dlFileEntryUploadProgress";

FileEntry fileEntry = (FileEntry)request.getAttribute(WebKeys.DOCUMENT_LIBRARY_FILE_ENTRY);

long fileEntryId = fileEntry.getFileEntryId();
long folderId = fileEntry.getFolderId();
String extension = fileEntry.getExtension();
String title = fileEntry.getTitle();

Folder folder = fileEntry.getFolder();
FileVersion fileVersion = (FileVersion)request.getAttribute(WebKeys.DOCUMENT_LIBRARY_FILE_VERSION);

boolean versionSpecific = false;

if (fileVersion != null) {
	versionSpecific = true;
}
else if ((user.getUserId() == fileEntry.getUserId()) || permissionChecker.isCompanyAdmin() || permissionChecker.isGroupAdmin(scopeGroupId) || DLFileEntryPermission.contains(permissionChecker, fileEntry, ActionKeys.UPDATE)) {
	fileVersion = fileEntry.getLatestFileVersion();
}
else {
	fileVersion = fileEntry.getFileVersion();
}

long fileVersionId = fileVersion.getFileVersionId();

long fileEntryTypeId = 0;

if (fileVersion.getModel() instanceof DLFileVersion) {
	DLFileVersion dlFileVersion = (DLFileVersion)fileVersion.getModel();

	fileEntryTypeId = dlFileVersion.getFileEntryTypeId();
}

Lock lock = fileEntry.getLock();

String[] conversions = new String[0];

if (PrefsPropsUtil.getBoolean(PropsKeys.OPENOFFICE_SERVER_ENABLED, PropsValues.OPENOFFICE_SERVER_ENABLED)) {
	conversions = (String[])DocumentConversionUtil.getConversions(extension);
}

long assetClassPK = 0;

if (!fileVersion.isApproved() && !fileVersion.getVersion().equals(DLFileEntryConstants.VERSION_DEFAULT)) {
	assetClassPK = fileVersion.getFileVersionId();
	title = fileVersion.getTitle();
	extension = fileVersion.getExtension();
}
else {
	assetClassPK = fileEntry.getFileEntryId();
}

String webDavUrl = StringPool.BLANK;

if (portletDisplay.isWebDAVEnabled()) {
	webDavUrl = DLUtil.getWebDavURL(themeDisplay, folder, fileEntry);
}

boolean hasAudio = AudioProcessorUtil.hasAudio(fileVersion);
boolean hasImages = ImageProcessorUtil.hasImages(fileVersion);
boolean hasPDFImages = PDFProcessorUtil.hasImages(fileVersion);
boolean hasVideo = VideoProcessorUtil.hasVideo(fileVersion);

AssetEntry layoutAssetEntry = AssetEntryLocalServiceUtil.fetchEntry(DLFileEntryConstants.getClassName(), assetClassPK);

request.setAttribute(WebKeys.LAYOUT_ASSET_ENTRY, layoutAssetEntry);

request.setAttribute("view_file_entry.jsp-fileEntry", fileEntry);
%>

<portlet:actionURL var="editFileEntry">
	<portlet:param name="struts_action" value="/document_library/edit_file_entry" />
	<portlet:param name="fileEntryId" value="<%= String.valueOf(fileEntry.getFileEntryId()) %>" />
</portlet:actionURL>

<aui:form action="<%= editFileEntry %>" method="post" name="fm">
	<aui:input name="<%= Constants.CMD %>" type="hidden" />
	<aui:input name="redirect" type="hidden" value="<%= currentURL %>" />
</aui:form>

<c:if test="<%= folder != null %>">

	<%
	String versionText = null;

	if (Validator.isNotNull(fileVersion.getVersion())) {
		versionText = LanguageUtil.format(pageContext, "version-x", fileVersion.getVersion());
	}
	else {
		versionText = LanguageUtil.get(pageContext, "not-approved");
	}
	%>

	<liferay-ui:header
		backURL="<%= redirect %>"
		localizeTitle="<%= false %>"
		title="<%= fileEntry.getTitle() %>"
	/>
</c:if>

<div class="view">
	<aui:layout>
		<aui:column columnWidth="<%= 65 %>" cssClass="lfr-asset-column-details" first="<%= true %>">
			<div class="lfr-header-row">
				<div class="lfr-header-row-content">
					<aui:button-row cssClass="edit-toolbar" id='<%= renderResponse.getNamespace() + "fileEntryToolbar" %>' />
				</div>
			</div>

			<c:if test="<%= (fileEntry.getLock() != null) && DLFileEntryPermission.contains(permissionChecker, fileEntry, ActionKeys.UPDATE) %>">
				<c:choose>
					<c:when test="<%= fileEntry.hasLock() %>">
						<div class="portlet-msg-lock portlet-msg-success">
							<c:choose>
								<c:when test="<%= lock.isNeverExpires() %>">
									<liferay-ui:message key="you-now-have-an-indefinite-lock-on-this-document" />
								</c:when>
								<c:otherwise>

									<%
									String lockExpirationTime = LanguageUtil.getTimeDescription(pageContext, DLFileEntryConstants.LOCK_EXPIRATION_TIME).toLowerCase();
									%>

									<%= LanguageUtil.format(pageContext, "you-now-have-a-lock-on-this-document", lockExpirationTime, false) %>
								</c:otherwise>
							</c:choose>
						</div>
					</c:when>
					<c:otherwise>
						<div class="portlet-msg-error">
							<%= LanguageUtil.format(pageContext, "you-cannot-modify-this-document-because-it-was-locked-by-x-on-x", new Object[] {HtmlUtil.escape(PortalUtil.getUserName(lock.getUserId(), String.valueOf(lock.getUserId()))), dateFormatDateTime.format(lock.getCreateDate())}, false) %>
						</div>
					</c:otherwise>
				</c:choose>
			</c:if>

			<div class="body-row">
				<div class="document-info">
					<h2 class="document-title">
						<c:choose>
							<c:when test="<%= versionSpecific %>">
								<%= fileVersion.getTitle() %>

								(<liferay-ui:message key="version" /> <%= HtmlUtil.escape(fileVersion.getVersion()) %>)
							</c:when>
							<c:otherwise>
								<%= title %>
							</c:otherwise>
						</c:choose>
					</h2>

					<span class="document-thumbnail">

						<%
						DLFileShortcut dlFileShortcut = null;

						String thumbnailSrc = DLUtil.getThumbnailSrc(fileEntry, fileVersion, dlFileShortcut, themeDisplay);

						if (layoutAssetEntry != null) {
							AssetEntry incrementAssetEntry = AssetEntryServiceUtil.incrementViewCounter(layoutAssetEntry.getClassName(), fileEntry.getFileEntryId());

							if (incrementAssetEntry != null) {
								layoutAssetEntry = incrementAssetEntry;
							}
						}
						%>

						<img alt="" border="no" class="thumbnail" src="<%= thumbnailSrc %>" style="max-height: <%= PropsValues.DL_FILE_ENTRY_THUMBNAIL_MAX_HEIGHT %>px; max-width: <%= PropsValues.DL_FILE_ENTRY_THUMBNAIL_MAX_WIDTH %>px;" />
					</span>

					<span class="user-date">

							<%
							String displayURL = StringPool.BLANK;

							User userDisplay = UserLocalServiceUtil.fetchUser(fileEntry.getUserId());

							if (userDisplay != null) {
								displayURL = userDisplay.getDisplayURL(themeDisplay);
							}
							%>

						<liferay-ui:icon image="../document_library/add_document" label="<%= true %>" message='<%= LanguageUtil.format(pageContext, "uploaded-by-x-x", new Object[] {displayURL, HtmlUtil.escape(fileEntry.getUserName()), dateFormatDateTime.format(fileEntry.getCreateDate())}) %>' />
					</span>

					<c:if test="<%= fileEntry.isSupportsSocial() %>">
						<span class="lfr-asset-ratings">
							<liferay-ui:ratings
								className="<%= DLFileEntryConstants.getClassName() %>"
								classPK="<%= fileEntryId %>"
							/>
						</span>
					</c:if>

					<c:if test="<%= enableRelatedAssets && fileEntry.isSupportsSocial() %>">
						<div class="entry-links">
							<liferay-ui:asset-links
								assetEntryId="<%= layoutAssetEntry.getEntryId() %>"
							/>
						</div>
					</c:if>

					<span class="document-description">
						<%= HtmlUtil.escape(fileVersion.getDescription()) %>
					</span>

					<c:if test="<%= fileEntry.isSupportsSocial() %>">
						<div class="lfr-asset-categories">
							<liferay-ui:asset-categories-summary
								className="<%= DLFileEntryConstants.getClassName() %>"
								classPK="<%= assetClassPK %>"
							/>
						</div>

						<div class="lfr-asset-tags">
							<liferay-ui:asset-tags-summary
								className="<%= DLFileEntryConstants.getClassName() %>"
								classPK="<%= assetClassPK %>"
								message="tags"
							/>
						</div>
					</c:if>
					
					<!-- If fileEntry.isCheckedOut, locked and is an images  -->
					<c:if test="<%= fileEntry.isCheckedOut() && fileEntry.hasLock() && hasImages %>">
			            
			            <!--Insert selector-->
			            <fieldset width="90%" class="fieldsetFilterEdit" >

			            	<legend><liferay-ui:message key="filtereditor.legend"/></legend>
			            	
			            	<div class="filterConfigurationType">
								<input type="radio" name="filterConfigurationType" value="preset" checked="checked"/><liferay-ui:message key="filterConfigurationType.preset"/>
								<input type="radio" name="filterConfigurationType" value="configure"/><liferay-ui:message key="filterConfigurationType.configure"/>
							</div>
			            	
							<table align="left" style="text-align: left">
							
								<tr class="columnFilterPreset">
									<td class="columnFilterPreset"><b><liferay-ui:message key="filter.presets"/></b></td>
									<td>              
					                    <select id="selectedvintagefilter" onchange="applyvintagefilter('<%= title %>');">
					                        <option value="0"><liferay-ui:message key="filter.presets.custom"/></option>
					                        <option value="1"><liferay-ui:message key="filter.presets.green"/></option>
					                        <option value="2"><liferay-ui:message key="filter.presets.sepia"/></option>
					                        <option value="3"><liferay-ui:message key="filter.presets.grayscale"/></option>
					                        <option value="4"><liferay-ui:message key="filter.presets.default"/></option>
					                    </select>
					                </td>
								</tr>
								
								<tr class="columnFilterEdit">
									<td><b><liferay-ui:message key="filter.vignette.darken"/></b></td>
									<td><div id="blue"></div></td>
								</tr>
								<tr class="columnFilterEdit">
									<td><b><liferay-ui:message key="filter.vignette.lighten"/></b></td>
									<td><div id="blue"></div></td>
								</tr>
								<tr class="columnFilterEdit">
									<td><b><liferay-ui:message key="filter.adjust.curves"/></b></td>
									<td><div id="green"></div></td>
								</tr>
								<tr class="columnFilterEdit">
									<td><b><liferay-ui:message key="filter.screenlayer"/></b></td>
									<td><div id="blue"></div></td>
								</tr>
								<tr class="columnFilterEdit">
									<td><b><liferay-ui:message key="filter.viewfinder"/></b></td>
									<td><div id="red"></div></td>
								</tr>
								<tr class="columnFilterEdit">
									<td><b><liferay-ui:message key="filter.desaturate"/></b></td>
									<td><div id="blue"></div></td>
								</tr>
								<tr class="columnFilterEdit">
									<td><b><liferay-ui:message key="filter.blur.edges"/></b></td>
									<td><div id="green"></div></td>
								</tr>
								
								<tr>
									<td class="columnFilterBotton" colspan="2" align="center" >
										<br/>
										<!-- <input type="button" id="filterImageBotton" value='<liferay-ui:message key="filter.filter"/>' /> -->
										<input type="button" id="saveImageBotton" 	value='<liferay-ui:message key="filter.save"/>' />
									</td>
								</tr>
							</table>
						</fieldset>
			            <!--Insert selector-->
			            
					</c:if>

				</div>

				<aui:model-context bean="<%= fileVersion %>" model="<%= DLFileVersion.class %>" />

				<c:if test="<%= PropsValues.DL_FILE_ENTRY_PREVIEW_ENABLED %>">
					<div>

						<%
						int previewFileCount = 0;
						String previewFileURL = null;
						String[] previewFileURLs = null;
						String videoThumbnailURL = null;

						String previewQueryString = null;

						if (hasAudio) {
							previewQueryString = "&audioPreview=1";
						}
						else if (hasImages) {
							previewQueryString = "&imagePreview=1";
						}
						else if (hasPDFImages) {
							previewFileCount = PDFProcessorUtil.getPreviewFileCount(fileVersion);

							previewQueryString = "&previewFileIndex=";

							previewFileURL = DLUtil.getPreviewURL(fileEntry, fileVersion, themeDisplay, previewQueryString);
						}
						else if (hasVideo) {
							previewQueryString = "&videoPreview=1";

							videoThumbnailURL = DLUtil.getPreviewURL(fileEntry, fileVersion, themeDisplay, "&videoThumbnail=1");
						}

						if (Validator.isNotNull(previewQueryString)) {
							if (hasAudio) {
								previewFileURLs = new String[PropsValues.DL_FILE_ENTRY_PREVIEW_AUDIO_CONTAINERS.length];

								for (int i = 0; i < PropsValues.DL_FILE_ENTRY_PREVIEW_AUDIO_CONTAINERS.length; i++) {
									previewFileURLs[i] = DLUtil.getPreviewURL(fileEntry, fileVersion, themeDisplay, previewQueryString + "&type=" + PropsValues.DL_FILE_ENTRY_PREVIEW_AUDIO_CONTAINERS[i]);
								}
							}
							else if (hasVideo) {
								if (PropsValues.DL_FILE_ENTRY_PREVIEW_VIDEO_CONTAINERS.length > 0) {
									previewFileURLs = new String[PropsValues.DL_FILE_ENTRY_PREVIEW_VIDEO_CONTAINERS.length];

									for (int i = 0; i < PropsValues.DL_FILE_ENTRY_PREVIEW_VIDEO_CONTAINERS.length; i++) {
										previewFileURLs[i] = DLUtil.getPreviewURL(fileEntry, fileVersion, themeDisplay, previewQueryString + "&type=" + PropsValues.DL_FILE_ENTRY_PREVIEW_VIDEO_CONTAINERS[i]);
									}
								}
								else {
									previewFileURLs = new String[1];

									previewFileURLs[0] = videoThumbnailURL;
								}
							}
							else {
								previewFileURLs = new String[1];

								previewFileURLs[0] = DLUtil.getPreviewURL(fileEntry, fileVersion, themeDisplay, previewQueryString);
							}

							previewFileURL = previewFileURLs[0];

							if (!hasPDFImages) {
								previewFileCount = 1;
							}
						}

						request.setAttribute("view_file_entry.jsp-supportedAudio", String.valueOf(hasAudio));
						request.setAttribute("view_file_entry.jsp-supportedVideo", String.valueOf(hasVideo));

						request.setAttribute("view_file_entry.jsp-previewFileURLs", previewFileURLs);
						request.setAttribute("view_file_entry.jsp-videoThumbnailURL", videoThumbnailURL);
						%>

						<c:choose>
							<c:when test="<%= previewFileCount == 0 %>">
								<c:if test="<%= AudioProcessorUtil.isAudioSupported(fileVersion) || ImageProcessorUtil.isImageSupported(fileVersion) || PDFProcessorUtil.isDocumentSupported(fileVersion) || VideoProcessorUtil.isVideoSupported(fileVersion) %>">
									<div class="portlet-msg-info">
										<liferay-ui:message key="generating-preview-will-take-a-few-minutes" />
									</div>
								</c:if>
							</c:when>
							<c:otherwise>
								<c:choose>
									<c:when test="<%= hasAudio %>">
										<div class="lfr-preview-audio" id="<portlet:namespace />previewFile">
											<div class="lfr-preview-audio-content" id="<portlet:namespace />previewFileContent"></div>
										</div>

										<liferay-util:include page="/html/portlet/document_library/player.jsp" />
									</c:when>
									<c:when test="<%= hasImages %>">
										<div class="lfr-preview-file lfr-preview-image" id="<portlet:namespace />previewFile">
											<div class="lfr-preview-file-content lfr-preview-image-content" id="<portlet:namespace />previewFileContent">
												<div class="lfr-preview-file-image-current-column">
													<div class="lfr-preview-file-image-container">
														<img class="lfr-preview-file-image-current" src="<%= previewFileURL %>" />
													</div>
												</div>
											</div>
										</div>
									</c:when>
									<c:when test="<%= hasVideo %>">
										<div class="lfr-preview-file lfr-preview-video" id="<portlet:namespace />previewFile">
											<div class="lfr-preview-file-content lfr-preview-video-content">
												<div class="lfr-preview-file-video-current-column">
													<div id="<portlet:namespace />previewFileContent"></div>
												</div>
											</div>
										</div>

										<liferay-util:include page="/html/portlet/document_library/player.jsp" />
									</c:when>
									<c:otherwise>
										<div class="lfr-preview-file" id="<portlet:namespace />previewFile">
											<div class="lfr-preview-file-content" id="<portlet:namespace />previewFileContent">
												<div class="lfr-preview-file-image-current-column">
													<div class="lfr-preview-file-image-container">
														<img class="lfr-preview-file-image-current" id="<portlet:namespace />previewFileImage" src="<%= previewFileURL + "1" %>" />
													</div>
													<span class="lfr-preview-file-actions aui-helper-hidden" id="<portlet:namespace />previewFileActions">
														<span class="lfr-preview-file-toolbar" id="<portlet:namespace />previewToolbar"></span>

														<span class="lfr-preview-file-info">
															<span class="lfr-preview-file-index" id="<portlet:namespace />previewFileIndex">1</span> of <span class="lfr-preview-file-count"><%= previewFileCount %></span>
														</span>
													</span>
												</div>

												<div class="lfr-preview-file-images" id="<portlet:namespace />previewImagesContent">
													<div class="lfr-preview-file-images-content"></div>
												</div>
											</div>
										</div>

										<aui:script use="aui-base,liferay-preview">
											new Liferay.Preview(
												{
													actionContent: '#<portlet:namespace />previewFileActions',
													baseImageURL: '<%= previewFileURL %>',
													boundingBox: '#<portlet:namespace />previewFile',
													contentBox: '#<portlet:namespace />previewFileContent',
													currentPreviewImage: '#<portlet:namespace />previewFileImage',
													imageListContent: '#<portlet:namespace />previewImagesContent',
													maxIndex: <%= previewFileCount %>,
													previewFileIndexNode: '#<portlet:namespace />previewFileIndex',
													toolbar: '#<portlet:namespace />previewToolbar'
												}
											).render();
										</aui:script>
									</c:otherwise>
								</c:choose>
							</c:otherwise>
						</c:choose>
					</div>
				</c:if>

				<c:if test="<%= PropsValues.DL_FILE_ENTRY_COMMENTS_ENABLED %>">
					<liferay-ui:panel collapsible="<%= true %>" cssClass="lfr-document-library-comments" extended="<%= true %>" persistState="<%= true %>" title="comments">
						<portlet:actionURL var="discussionURL">
							<portlet:param name="struts_action" value="/document_library/edit_file_entry_discussion" />
						</portlet:actionURL>

						<liferay-ui:discussion
							className="<%= DLFileEntryConstants.getClassName() %>"
							classPK="<%= fileEntryId %>"
							formAction="<%= discussionURL %>"
							formName="fm2"
							ratingsEnabled="<%= enableCommentRatings %>"
							redirect="<%= currentURL %>"
							subject="<%= title %>"
							userId="<%= fileEntry.getUserId() %>"
						/>
					</liferay-ui:panel>
				</c:if>
			</div>

		</aui:column>

		<aui:column columnWidth="<%= 35 %>" cssClass="lfr-asset-column-details context-pane" last="<%= true %>">
			<div class="lfr-header-row">
				<div class="lfr-header-row-content"></div>
			</div>

			<div class="body-row asset-details">
				<div class="asset-details-content">
					<h3 class="version <%= fileEntry.isCheckedOut() ? "document-locked" : StringPool.BLANK %>">
						<liferay-ui:message key="version" /> <%= HtmlUtil.escape(fileVersion.getVersion()) %>
					</h3>

					<div class="lfr-asset-icon lfr-asset-author">
						<liferay-ui:message arguments="<%= HtmlUtil.escape(fileVersion.getStatusByUserName()) %>" key="last-updated-by-x" />
					</div>

					<div class="lfr-asset-icon lfr-asset-date">
						<%= dateFormatDateTime.format(fileVersion.getModifiedDate()) %>
					</div>

					<div class="lfr-asset-summary">
						<aui:workflow-status model="<%= DLFileEntry.class %>" status="<%= fileVersion.getStatus() %>" />
					</div>

					<c:if test="<%= Validator.isNotNull(fileVersion.getDescription()) %>">
						<blockquote class="lfr-asset-description">
							<%= HtmlUtil.escape(fileVersion.getDescription()) %>
						</blockquote>
					</c:if>

					<span class="download-document">
						<c:if test="<%= DLFileEntryPermission.contains(permissionChecker, fileEntry, ActionKeys.VIEW) %>">
							<liferay-ui:icon
								image="download"
								label="<%= true %>"
								message='<%= LanguageUtil.get(pageContext, "download") + " (" + TextFormatter.formatKB(fileVersion.getSize(), locale) + "k)" %>'
								url="<%= DLUtil.getPreviewURL(fileEntry, fileVersion, themeDisplay, StringPool.BLANK) %>"
							/>
						</c:if>
					</span>

					<span class="conversions">

						<%
						for (int i = 0; i < conversions.length; i++) {
							String conversion = conversions[i];
						%>

							<liferay-ui:icon
								image='<%= "../file_system/small/" + conversion %>'
								label="<%= true %>"
								message="<%= conversion.toUpperCase() %>"
								url='<%= DLUtil.getPreviewURL(fileEntry, fileVersion, themeDisplay, "&targetExtension=" + conversion) %>'
							/>

						<%
						}
						%>

					</span>

					<span class="webdav-url">
						<c:choose>
							<c:when test="<%= portletDisplay.isWebDAVEnabled() && fileEntry.isSupportsSocial() %>">
								<liferay-ui:message key="get-url-or-webdav-url" />
							</c:when>

							<c:otherwise>
								<liferay-ui:message key="get-url" />
							</c:otherwise>
						</c:choose>
					</span>

					<div class="lfr-asset-field url-file-container aui-helper-hidden">
						<label><liferay-ui:message key="url" /></label>

						<liferay-ui:input-resource
							url="<%= DLUtil.getPreviewURL(fileEntry, fileEntry.getFileVersion(), themeDisplay, StringPool.BLANK, false, true) %>"
						/>
					</div>

					<c:if test="<%= portletDisplay.isWebDAVEnabled() && fileEntry.isSupportsSocial() %>">
						<div class="lfr-asset-field webdav-url-file-container aui-helper-hidden">

							<%
							String webDavHelpMessage = null;

							if (BrowserSnifferUtil.isWindows(request)) {
								webDavHelpMessage = LanguageUtil.format(pageContext, "webdav-windows-help", new Object[] {"http://www.microsoft.com/downloads/details.aspx?FamilyId=17C36612-632E-4C04-9382-987622ED1D64", "http://www.liferay.com/web/guest/community/wiki/-/wiki/Main/WebDAV"});
							}
							else {
								webDavHelpMessage = LanguageUtil.format(pageContext, "webdav-help", "http://www.liferay.com/web/guest/community/wiki/-/wiki/Main/WebDAV");
							}
							%>

							<aui:field-wrapper helpMessage="<%= webDavHelpMessage %>" label="webdav-url">
								<liferay-ui:input-resource url="<%= webDavUrl %>" />
							</aui:field-wrapper>
						</div>
					</c:if>
				</div>

				<%
				request.removeAttribute(WebKeys.SEARCH_CONTAINER_RESULT_ROW);
				%>

				<div class="lfr-asset-panels">
					<liferay-ui:panel-container extended="<%= false %>" id="documentLibraryAssetPanelContainer" persistState="<%= true %>">

						<%
						if (fileEntryTypeId > 0) {
							try {
								DLFileEntryType fileEntryType = DLFileEntryTypeServiceUtil.getFileEntryType(fileEntryTypeId);

								List<DDMStructure> ddmStructures = fileEntryType.getDDMStructures();

								for (DDMStructure ddmStructure : ddmStructures) {
									Fields fields = null;

									try {
										DLFileEntryMetadata fileEntryMetadata = DLFileEntryMetadataLocalServiceUtil.getFileEntryMetadata(ddmStructure.getStructureId(), fileVersionId);

										fields = StorageEngineUtil.getFields(fileEntryMetadata.getDDMStorageId());
									}
									catch (Exception e) {
									}
						%>

									<liferay-ui:panel collapsible="<%= true %>" cssClass="metadata" extended="<%= true %>" id="documentLibraryMetadataPanel" persistState="<%= true %>" title="<%= HtmlUtil.escape(ddmStructure.getName(LocaleUtil.getDefault())) %>">

										<%= DDMXSDUtil.getHTML(pageContext, ddmStructure.getXsd(), fields, String.valueOf(ddmStructure.getPrimaryKey()), true, locale) %>

									</liferay-ui:panel>

						<%
								}
							}
							catch (Exception e) {
							}
						}
						%>

						<liferay-ui:custom-attributes-available className="<%= DLFileEntryConstants.getClassName() %>" classPK="<%= fileVersionId %>" editable="<%= false %>">
							<liferay-ui:panel collapsible="<%= true %>" cssClass="custom-fields" id="documentLibraryCustomAttributesPanel" persistState="<%= true %>" title="custom-fields">
								<liferay-ui:custom-attribute-list
									className="<%= DLFileEntryConstants.getClassName() %>"
									classPK="<%= fileVersionId %>"
									editable="<%= false %>"
									label="<%= true %>"
								/>
							</liferay-ui:panel>
						</liferay-ui:custom-attributes-available>

						<%
						try {
							List<DDMStructure> ddmStructures = DDMStructureLocalServiceUtil.getClassStructures(PortalUtil.getClassNameId(DLFileEntry.class), new StructureStructureKeyComparator(true));

							for (DDMStructure ddmStructure : ddmStructures) {
								Fields fields = null;

								try {
									DLFileEntryMetadata fileEntryMetadata = DLFileEntryMetadataLocalServiceUtil.getFileEntryMetadata(ddmStructure.getStructureId(), fileVersionId);

									fields = StorageEngineUtil.getFields(fileEntryMetadata.getDDMStorageId());
								}
								catch (Exception e) {
								}

								if (fields != null) {
									String name = "metadata." + ddmStructure.getName(LocaleUtil.getDefault(), true);
						%>

									<liferay-ui:panel collapsible="<%= true %>" cssClass="lfr-asset-metadata" id="documentLibraryAssetMetadataPanel" persistState="<%= true %>" title="<%= name %>">

										<%= DDMXSDUtil.getHTML(pageContext, ddmStructure.getXsd(), fields, String.valueOf(ddmStructure.getPrimaryKey()), true, locale) %>

									</liferay-ui:panel>

						<%
								}
							}
						}
						catch (Exception e) {
						}
						%>

						<liferay-ui:panel collapsible="<%= true %>" cssClass="version-history" id="documentLibraryVersionHistoryPanel" persistState="<%= true %>" title="version-history">

							<%
							boolean comparableFileEntry = DocumentConversionUtil.isComparableVersion(extension);
							boolean showNonApprovedDocuments = false;

							if ((user.getUserId() == fileEntry.getUserId()) || permissionChecker.isCompanyAdmin() || permissionChecker.isGroupAdmin(scopeGroupId)) {
								showNonApprovedDocuments = true;
							}

							SearchContainer searchContainer = new SearchContainer();

							List<String> headerNames = new ArrayList<String>();

							headerNames.add("version");
							headerNames.add("date");
							headerNames.add("size");

							if (showNonApprovedDocuments) {
								headerNames.add("status");
							}

							headerNames.add(StringPool.BLANK);

							searchContainer.setHeaderNames(headerNames);

							PortletURL viewFileEntryURL = renderResponse.createRenderURL();

							viewFileEntryURL.setParameter("struts_action", "/document_library/view_file_entry");
							viewFileEntryURL.setParameter("redirect", currentURL);
							viewFileEntryURL.setParameter("fileEntryId", String.valueOf(fileEntry.getFileEntryId()));

							searchContainer.setIteratorURL(viewFileEntryURL);

							if (comparableFileEntry) {
								RowChecker rowChecker = new RowChecker(renderResponse);

								rowChecker.setAllRowIds(null);

								searchContainer.setRowChecker(rowChecker);
							}

							int status = WorkflowConstants.STATUS_APPROVED;

							if (showNonApprovedDocuments) {
								status = WorkflowConstants.STATUS_ANY;
							}

							List results = fileEntry.getFileVersions(status);
							List resultRows = searchContainer.getResultRows();

							for (int i = 0; i < results.size(); i++) {
								FileVersion curFileVersion = (FileVersion)results.get(i);

								ResultRow row = new ResultRow(new Object[] {fileEntry, curFileVersion, results.size(), conversions, fileEntry.isCheckedOut(), fileEntry.hasLock()}, String.valueOf(curFileVersion.getVersion()), i);

								// Statistics

								row.addText(String.valueOf(curFileVersion.getVersion()));
								row.addText(dateFormatDateTime.format(curFileVersion.getCreateDate()));
								row.addText(TextFormatter.formatKB(curFileVersion.getSize(), locale) + "k");

								// Status

								if (showNonApprovedDocuments) {
									row.addText(LanguageUtil.get(pageContext, WorkflowConstants.toLabel(curFileVersion.getStatus())));
								}

								// Action

								row.addJSP("right", SearchEntry.DEFAULT_VALIGN, "/html/portlet/document_library/file_entry_history_action.jsp");

								// Add result row

								resultRows.add(row);
							}

							if (comparableFileEntry && !results.isEmpty()) {
								FileVersion curFileVersion = (FileVersion)results.get(0);
							%>

								<portlet:actionURL var="compareVersionsURL">
									<portlet:param name="struts_action" value="/document_library/compare_versions" />
								</portlet:actionURL>

								<aui:form action="<%= compareVersionsURL %>" method="post" name="fm1" onSubmit='<%= "event.preventDefault(); " + renderResponse.getNamespace() + "compare();" %>'>
									<aui:input name="backURL" type="hidden" value="<%= currentURL %>" />
									<aui:input name="fileEntryId" type="hidden" value="<%= fileEntryId %>" />
									<aui:input name="sourceVersion" type="hidden" value="<%= curFileVersion.getVersion() %>" />
									<aui:input name="targetVersion" type="hidden" value="<%= fileEntry.getVersion() %>" />

									<aui:button-row>
										<aui:button type="submit" value="compare-versions" />
									</aui:button-row>
								</aui:form>

							<%
							}
							%>

							<liferay-ui:search-iterator paginate="<%= false %>" searchContainer="<%= searchContainer %>" />
						</liferay-ui:panel>
					</liferay-ui:panel-container>
				</div>
			</div>
		</aui:column>
	</aui:layout>
</div>

<aui:script>
	Liferay.provide(
		window,
		'<portlet:namespace />compare',
		function() {
			var A = AUI();

			var rowIds = A.all('input[name=<portlet:namespace />rowIds]:checked');
			var sourceVersion = A.one('input[name="<portlet:namespace />sourceVersion"]');
			var targetVersion = A.one('input[name="<portlet:namespace />targetVersion"]');

			var rowIdsSize = rowIds.size();

			if (rowIdsSize == 1) {
				if (sourceVersion) {
					sourceVersion.val(rowIds.item(0).val());
				}
			}
			else if (rowIdsSize == 2) {
				if (sourceVersion) {
					sourceVersion.val(rowIds.item(1).val());
				}

				if (targetVersion) {
					targetVersion.val(rowIds.item(0).val());
				}
			}

			submitForm(document.<portlet:namespace />fm1);
		},
		['aui-base', 'selector-css3']
	);

	Liferay.provide(
		window,
		'<portlet:namespace />initRowsChecked',
		function() {
			var A = AUI();

			var rowIds = A.all('input[name=<portlet:namespace />rowIds]');

			rowIds.each(
				function(item, index, collection) {
					if (index >= 2) {
						item.set('checked', false);
					}
				}
			);
		},
		['aui-base']
	);

	Liferay.provide(
		window,
		'<portlet:namespace />updateRowsChecked',
		function(element) {
			var A = AUI();

			var rowsChecked = A.all('input[name=<portlet:namespace />rowIds]:checked');

			if (rowsChecked.size() > 2) {
				var index = 2;

				if (rowsChecked.item(2).compareTo(element)) {
					index = 1;
				}

				rowsChecked.item(index).set('checked', false);
			}
		},
		['aui-base', 'selector-css3']
	);
</aui:script>

<aui:script use="aui-base,aui-toolbar">
	var showURLFile = A.one('.show-url-file');
	var showWebDavFile = A.one('.show-webdav-url-file');

	if (showURLFile) {
		showURLFile.on(
			'click',
			function(event) {
				var URLFileContainer = A.one('.url-file-container');

				URLFileContainer.toggleClass('aui-helper-hidden');
			}
		);
	}

	if (showWebDavFile) {
		showWebDavFile.on(
			'click',
			function(event) {
				var WebDavFileContainer = A.one('.webdav-url-file-container');

				WebDavFileContainer.toggleClass('aui-helper-hidden');
			}
		);
	}

	var buttonRow = A.one('#<portlet:namespace />fileEntryToolbar');

	var fileEntryToolbarChildren = [];

	<c:if test="<%= DLFileEntryPermission.contains(permissionChecker, fileEntry, ActionKeys.VIEW) %>">
		fileEntryToolbarChildren.push(
			{
				handler: function(event) {
					location.href = '<%= DLUtil.getPreviewURL(fileEntry, fileVersion, themeDisplay, StringPool.BLANK) %>';
				},
				icon: 'download',
				label: '<%= UnicodeLanguageUtil.get(pageContext, "download") %>'
			}
		);
	</c:if>

	<c:if test="<%= DLFileEntryPermission.contains(permissionChecker, fileEntry, ActionKeys.UPDATE) && (!fileEntry.isCheckedOut() || fileEntry.hasLock()) %>">
		fileEntryToolbarChildren.push(
			{

				<portlet:renderURL var="editURL">
					<portlet:param name="struts_action" value="/document_library/edit_file_entry" />
					<portlet:param name="redirect" value="<%= currentURL %>" />
					<portlet:param name="fileEntryId" value="<%= String.valueOf(fileEntry.getFileEntryId()) %>" />
				</portlet:renderURL>

				handler: function(event) {
					location.href = '<%= editURL.toString() %>';
				},
				icon: 'edit',
				label: '<%= UnicodeLanguageUtil.get(pageContext, "edit") %>'
			},
			{

				<portlet:renderURL var="moveURL">
					<portlet:param name="struts_action" value="/document_library/move_file_entry" />
					<portlet:param name="redirect" value="<%= currentURL %>" />
					<portlet:param name="fileEntryId" value="<%= String.valueOf(fileEntry.getFileEntryId()) %>" />
				</portlet:renderURL>

				handler: function(event) {
					location.href = '<%= moveURL.toString() %>';
				},
				icon: 'move',
				label: '<%= UnicodeLanguageUtil.get(pageContext, "move") %>'
			}
		);

		<c:if test="<%= !fileEntry.isCheckedOut() %>">
			fileEntryToolbarChildren.push(
				{

					handler: function(event) {
						document.<portlet:namespace />fm.<portlet:namespace /><%= Constants.CMD %>.value = '<%= Constants.CHECKOUT %>';
						submitForm(document.<portlet:namespace />fm);
					},
					icon: 'lock',
					label: '<%= UnicodeLanguageUtil.get(pageContext, "checkout[document]") %>'
				}
			);
		</c:if>

		<c:if test="<%= fileEntry.isCheckedOut() && fileEntry.hasLock() %>">
			fileEntryToolbarChildren.push(
				{

					handler: function(event) {
						document.<portlet:namespace />fm.<portlet:namespace /><%= Constants.CMD %>.value = '<%= Constants.CANCEL_CHECKOUT %>';
						submitForm(document.<portlet:namespace />fm);
					},
					icon: 'undo',
					label: '<%= UnicodeLanguageUtil.get(pageContext, "cancel-checkout[document]") %>'
				},
				{

					handler: function(event) {
						document.<portlet:namespace />fm.<portlet:namespace /><%= Constants.CMD %>.value = '<%= Constants.CHECKIN %>';
						submitForm(document.<portlet:namespace />fm);
					},
					icon: 'unlock',
					label: '<%= UnicodeLanguageUtil.get(pageContext, "checkin") %>'
				}
			);
		</c:if>
	</c:if>

	<c:if test="<%= DLFileEntryPermission.contains(permissionChecker, fileEntry, ActionKeys.PERMISSIONS) %>">
		fileEntryToolbarChildren.push(
			{
				<liferay-security:permissionsURL
					modelResource="<%= DLFileEntryConstants.getClassName() %>"
					modelResourceDescription="<%= fileEntry.getTitle() %>"
					resourcePrimKey="<%= String.valueOf(fileEntry.getFileEntryId()) %>"
					var="permissionsURL"
				/>

				handler: function(event) {
					location.href = '<%= permissionsURL.toString() %>';
				},
				icon: 'permissions',
				label: '<%= UnicodeLanguageUtil.get(pageContext, "permissions") %>'
			}
		);
	</c:if>

	<c:if test="<%= DLFileEntryPermission.contains(permissionChecker, fileEntry, ActionKeys.DELETE) %>">
		fileEntryToolbarChildren.push(
			{
				<portlet:renderURL var="viewFolderURL">
					<portlet:param name="struts_action" value="/document_library/view" />
					<portlet:param name="folderId" value="<%= String.valueOf(fileEntry.getFolderId()) %>" />
				</portlet:renderURL>

				handler: function(event) {
					if (confirm('<%= UnicodeLanguageUtil.get(pageContext, "are-you-sure-you-want-to-delete-this-entry") %>')) {
						document.<portlet:namespace />fm.<portlet:namespace /><%= Constants.CMD %>.value = '<%= Constants.DELETE %>';
						document.<portlet:namespace />fm.<portlet:namespace />redirect.value = '<%= viewFolderURL.toString() %>';
						submitForm(document.<portlet:namespace />fm);
					}
				},
				icon: 'delete',
				label: '<%= UnicodeLanguageUtil.get(pageContext, "delete") %>'
			}
		);
	</c:if>

	var fileEntryToolbar = new A.Toolbar(
		{
			activeState: false,
			boundingBox: buttonRow,
			children: fileEntryToolbarChildren
		}
	).render();

	buttonRow.setData('fileEntryToolbar', fileEntryToolbar);

	<portlet:namespace />initRowsChecked();

	A.all('input[name=<portlet:namespace />rowIds]').on(
		'click',
		function(event) {
			<portlet:namespace />updateRowsChecked(event.currentTarget);
		}
	);
</aui:script>

<%
DLUtil.addPortletBreadcrumbEntries(fileEntry, request, renderResponse);
%>