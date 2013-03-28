package com.liferay.portlet.documentlibrary.conversors;

import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.File;
import javax.imageio.ImageIO;
import javax.xml.bind.DatatypeConverter;

public class DecodeImage {
	public static void main(String[] args) {
		try {
			// remove data:image/png;base64, and then take rest sting
			String img64 = "64 base image data here";
			byte[] decodedBytes = DatatypeConverter.parseBase64Binary(img64);
			BufferedImage bfi = ImageIO.read(new ByteArrayInputStream(decodedBytes));
			File outputfile = new File("saved.png");
			ImageIO.write(bfi, "png", outputfile);
			bfi.flush();
		} catch (Exception e) {
			// Implement exception code
		}
	}
}

