function image = drawFPImageProb(image,p)


maxim = double(max(max(image)));

text1 = text2im(['PFP : ' num2str(p.PFP)]).*maxim;
text2 = text2im(['PB : ' num2str(p.PB)])*maxim;
text3 = text2im(['PRA : ' num2str(p.PRA)])*maxim;
text4 = text2im(['PWL : ' num2str(p.PWL)])*maxim;
text5 = text2im(['PWW : ' num2str(p.PWW)])*maxim;
text6 = text2im(['PBR : ' num2str(p.PBR)])*maxim;
text7 = text2im(['PA : ' num2str(p.PA)])*maxim;
text8 = text2im(['PN : ' num2str(p.PN)])*maxim;
text9 = text2im(['enter : ' num2str(p.enter)])*maxim;
image(50:size(text1,1)+49,50:size(text1,2)+49,:) = text1;
image(100:size(text2,1)+99,50:size(text2,2)+49,:) = text2;
image(150:size(text3,1)+149,50:size(text3,2)+49,:) = text3;
image(200:size(text4,1)+199,50:size(text4,2)+49,:) = text4;
image(250:size(text5,1)+249,50:size(text5,2)+49,:) = text5;
image(300:size(text6,1)+299,50:size(text6,2)+49,:) = text6;
image(350:size(text7,1)+349,50:size(text7,2)+49,:) = text7;
image(400:size(text8,1)+399,50:size(text8,2)+49,:) = text8;
image(450:size(text9,1)+449,50:size(text9,2)+49,:) = text9;
