if [ "$2" == "www" ];then
	echo 'www change'
	wwwDir='/Users/polylink/Dev/project/HBuilderProjects/WeTalkHb/'
	files='audio/ bower_components/ contact_main.html css/ fonts/ guide.html icons/ img/ index.html js/ cropper.html personal.html setting.html splash.html'
	for data in $files  
	do  
    		rm -rf ${data}
    		cp -rf ${wwwDir}${data} ./${data}  
	done
	rm -rf  **/.svn
fi

wetalkDir='/Users/polylink/Dev/project/HBuilderProjects/WeTalkVersionResource/'
resDir=$wetalkDir'unpackage/res/'
xcodeDir='../../../../'
appicon='../../../../../HBuilder/Images.xcassets/AppIcon.appiconset/'
#manifest.json
rm -rf manifest.json
cp -rf  $resDir'manifest'$1'.json' manifest.json

rm -rf $xcodeDir'icon' $xcodeDir'splash'
mkdir -p $xcodeDir'icon'
mkdir -p $xcodeDir'splash'
#icon
icons='87 180 120 144 152 29 40 58 72 76 80'
for icon in $icons
do
    cp -rf $resDir'icons'$1'/'$icon'x'$icon'.png' $xcodeDir'icon/icon'$icon'.png'
    cp -rf $resDir'icons'$1'/'$icon'x'$icon'.png' $appicon'icon'$icon'.png'
done
#splash
cp -rf $resDir'launch'$1'/LaunchScreen568h@2x.png' $xcodeDir'splash/Default-568h@2x.png'
cp -rf $resDir'launch'$1'/LaunchScreen667h@2x.png' $xcodeDir'splash/Default-667h@2x.png'
cp -rf $resDir'launch'$1'/LaunchScreenPort736h@3x.png' $xcodeDir'splash/Default-736h@3x.png'
cp -rf $resDir'launch'$1'/X.png' $xcodeDir'splash/Default-812h@3x.png'
cp -rf $resDir'launch'$1'/LaunchScreenLand736h@3x.png' $xcodeDir'splash/Default-Landscape-736h@3x.png'
cp -rf $resDir'launch'$1'/X2436_1125.png' $xcodeDir'splash/Default-Landscape-812h@3x.png'

#info.plist
#rm -rf '../../../../'$1'-Info.plist'
#cp -rf $wetalkDir$1'-Info.plist' '../../../../'$1'-Info.plist'

