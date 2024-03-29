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

import com.liferay.portal.kernel.util.StringPool;

/**
 * @author Mika Koivisto
 * @author Brian Wing Shun Chan
 */
public class Attribute {

	public Attribute(String name) {
		this(name, StringPool.BLANK, StringPool.BLANK);
	}

	public Attribute(String name, String newValue, String oldValue) {
		_name = name;
		_newValue = newValue;
		_oldValue = oldValue;
	}

	public String getName() {
		return _name;
	}

	public String getNewValue() {
		return _newValue;
	}

	public String getOldValue() {
		return _oldValue;
	}

	private String _name;
	private String _newValue;
	private String _oldValue;

}