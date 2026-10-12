package Widgets.Windows
{
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class IconTitleToasterWindow extends AutoCloseToasterWindow
   {
      
      public static const DIALOG_ASSET:String = "assets/dialogs/FV_Craft_BannerAd.swf";
      
      public static const ICON_SIZE_50:int = 50;
      
      public static const DEFAULT_ICON_SCALE:Number = 1;
      
      protected var m_title:String;
      
      protected var m_text:String;
      
      protected var m_iconUrl:String;
      
      protected var m_iconScale:Number = 1;
      
      protected var m_iconOffset:Point = null;
      
      protected var m_clickCallback:Function = null;
      
      protected var m_iconSize:int = 50;
      
      public function IconTitleToasterWindow(title:String, text:String, iconUrl:String, windowAssetPath:String = "assets/dialogs/FV_Craft_BannerAd.swf", iconScale:Number = 1, iconOffset:Point = null, clickCallback:Function = null, iconSize:int = 100)
      {
         super(windowAssetPath);
         this.m_title = title;
         this.m_text = text;
         this.m_iconUrl = iconUrl;
         this.m_iconScale = iconScale;
         this.m_iconOffset = iconOffset;
         this.m_clickCallback = clickCallback;
         this.m_iconSize = iconSize;
      }
      
      override protected function postLoadComplete() : void
      {
         var frame:ZwFrame = null;
         var icon:FarmIcon = null;
         super.postLoadComplete();
         if(m_windowAssetPath == "assets/dialogs/FV_BannerAd_Garages.swf")
         {
            ZLocUtils.setText(m_window,"bannerad_mc.buy_bt.generic_tf","FV_BannerAd_Garages","FV_BannerAd_Garages.bannerad_mc.buy_bt.generic_tf");
         }
         if(m_window.bannerad_mc)
         {
            frame = new ZwFrame(m_window.bannerad_mc);
            frame.addWidget(new ZwButton(m_window.bannerad_mc.close_bt,onClose));
            frame.addWidget(new ZwTextField(m_window.bannerad_mc.generic_tf,this.m_title));
            frame.addWidget(new ZwTextField(m_window.bannerad_mc.generic_desc_tf,this.m_text));
            if(m_window.bannerad_mc.icon_mc)
            {
               icon = frame.addWidget(new FarmIcon(m_window.bannerad_mc.icon_mc)) as FarmIcon;
               icon.setIconSize(this.m_iconSize,this.m_iconSize);
               if(m_windowAssetPath.indexOf("assets/dialogs/FV_DinoEscapade_BannerAd.swf") != -1 || this.m_title.indexOf("Roaming Dinosaurs") != -1)
               {
                  icon.setIconSize(100,100);
               }
               if(this.m_iconUrl)
               {
                  icon.loadIcon(this.m_iconUrl);
               }
               m_window.bannerad_mc.icon_mc.scaleX = this.m_iconScale;
               m_window.bannerad_mc.icon_mc.scaleY = this.m_iconScale;
               if(this.m_iconOffset != null)
               {
                  m_window.bannerad_mc.icon_mc.x += this.m_iconOffset.x;
                  m_window.bannerad_mc.icon_mc.y += this.m_iconOffset.y;
               }
            }
            addWidget(frame);
            if(this.m_clickCallback != null)
            {
               frame.registerEventListener(MouseEvent.CLICK,this.m_clickCallback);
            }
         }
         else if(Config.DEBUG_MODE)
         {
            UI.displayMessage("missing bannerad_mc in " + this.m_windowAssetPath);
         }
      }
      
      public function get timeToLive() : Number
      {
         return m_timeToLive;
      }
   }
}

