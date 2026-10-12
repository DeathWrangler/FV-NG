package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.GroomingBarnManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class YearlingShareWindow extends FarmWindow
   {
      
      private static const DARK_YEARLING:String = "horse_yearlingdark";
      
      private static const LIGHT_YEARLING:String = "horse_lightyearling";
      
      private static const PEGASUS_YEARLING:String = "horse_yearlingpegasus";
      
      private static const UNICORN_YEARLING:String = "horse_yearlingunicorn";
      
      private var m_shareCallback:Function;
      
      private var m_coltName:String;
      
      private var m_adultItem:FarmItem;
      
      private var m_share:FarmAnimatedTextButton;
      
      private var m_adultIcon:ObjectPreviewFrame;
      
      private var m_darkYearling:MovieClip;
      
      private var m_lightYearling:MovieClip;
      
      private var m_pegasusYearling:MovieClip;
      
      private var m_unicornYearling:MovieClip;
      
      public function YearlingShareWindow(assetUrl:String = "assets/dialogs/FV_Yearlings_share.swf", shareCallback:Function = null, coltName:String = "", adultItem:FarmItem = null)
      {
         super(assetUrl);
         this.m_shareCallback = shareCallback;
         this.m_coltName = coltName;
         this.m_adultItem = adultItem;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"cashcalf_title")),true);
         }
         if(m_window.hasOwnProperty("generic_tf"))
         {
            addWidget(new ZwTextField(m_window.generic_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,GroomingBarnManager.getInstance().WINDOW_NAME + "_subtitle2Text")),true);
         }
         if(m_window.hasOwnProperty("share_bt"))
         {
            addWidget(this.m_share = new FarmAnimatedTextButton(m_window.share_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"ShareButton"),this.onShareClick),true);
         }
         if(m_window.hasOwnProperty("icon_1_mc"))
         {
            addWidget(this.m_adultIcon = new ObjectPreviewFrame(m_window.icon_1_mc,this.m_adultItem,null,null),true);
         }
         if(m_window.hasOwnProperty("dark_mc"))
         {
            this.m_darkYearling = m_window.dark_mc;
            this.m_darkYearling.visible = false;
         }
         if(m_window.hasOwnProperty("light_mc"))
         {
            this.m_lightYearling = m_window.light_mc;
            this.m_lightYearling.visible = false;
         }
         if(m_window.hasOwnProperty("pegasus_mc"))
         {
            this.m_pegasusYearling = m_window.pegasus_mc;
            this.m_pegasusYearling.visible = false;
         }
         if(m_window.hasOwnProperty("unicorn_mc"))
         {
            this.m_unicornYearling = m_window.unicorn_mc;
            this.m_unicornYearling.visible = false;
         }
         if(this.m_coltName)
         {
            this.showYearlingsTransform(this.m_coltName);
         }
      }
      
      private function showYearlingsTransform(coltName:String) : void
      {
         switch(coltName)
         {
            case LIGHT_YEARLING:
               this.m_lightYearling.visible = true;
               break;
            case DARK_YEARLING:
               this.m_darkYearling.visible = true;
               break;
            case PEGASUS_YEARLING:
               this.m_pegasusYearling.visible = true;
               break;
            case UNICORN_YEARLING:
               this.m_unicornYearling.visible = true;
         }
      }
      
      private function onShareClick(event:Event) : void
      {
         if(this.m_shareCallback != null)
         {
            this.m_shareCallback();
         }
         super.close();
      }
      
      override protected function release() : void
      {
         this.m_shareCallback = null;
         this.m_coltName = null;
         this.m_adultItem = null;
         this.m_share = null;
         this.m_adultIcon = null;
         this.m_darkYearling = null;
         this.m_lightYearling = null;
         this.m_pegasusYearling = null;
         this.m_unicornYearling = null;
         super.release();
      }
   }
}

