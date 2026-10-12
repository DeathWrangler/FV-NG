package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.AFInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class AFInnovationGameCongratsWindow extends FarmWindow
   {
      
      private static const OFFSET_OPF_Y:int = -30;
      
      protected var m_featureName:String = null;
      
      private var m_reward:FarmItem = null;
      
      private var m_callback:Function = null;
      
      protected var title_tf:ZwTextField = null;
      
      protected var m_zoomingScale:int = 3;
      
      public function AFInnovationGameCongratsWindow(dialogAsset:String, featureName:String, rewardItem:FarmItem = null, buttonCallback:Function = null, dialogBackground:String = null)
      {
         super(dialogAsset);
         this.m_reward = rewardItem;
         this.m_featureName = featureName;
         this.m_callback = buttonCallback;
      }
      
      override protected function postLoadComplete() : void
      {
         var buttonCallback:Function = null;
         var iconUrl:String = null;
         super.postLoadComplete();
         var itemName:String = "";
         if(this.m_reward != null)
         {
            itemName = this.m_reward.friendlyTitle;
         }
         if(m_window != null)
         {
            if(m_window.hasOwnProperty("generic_tf"))
            {
               this.title_tf = addWidget(new ZwTextField(m_window["generic_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_GameCongratsWindow_GenericText"))) as ZwTextField;
            }
            if(m_window.hasOwnProperty("generic2_tf"))
            {
               addWidget(new ZwTextField(m_window["generic2_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_GameCongratsWindow_Generic2Text")));
            }
            if(m_window.hasOwnProperty("generic3_tf"))
            {
               addWidget(new ZwTextField(m_window["generic3_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_GameCongratsWindow_Generic3Text")));
            }
            if(m_window.hasOwnProperty("generic4_tf"))
            {
               addWidget(new ZwTextField(m_window["generic4_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_GameCongratsWindow_Generic4Text")));
            }
            if(m_window.hasOwnProperty("quantity_tf"))
            {
               addWidget(new ZwTextField(m_window["quantity_tf"],"x20"));
            }
            if(m_window.hasOwnProperty("okay_bt"))
            {
               buttonCallback = this.onButtonClick;
               if(this.m_callback != null)
               {
                  buttonCallback = this.m_callback;
               }
               addWidget(new FarmAnimatedTextButton(m_window["okay_bt"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_GameCongratsWindow_ShareButtonText",{"itemName":itemName}),buttonCallback));
            }
            if(m_window.hasOwnProperty("icon_mc"))
            {
               iconUrl = this.m_reward.getImageByName(FarmItem.ICON_200);
               if(iconUrl == null)
               {
                  iconUrl = this.m_reward.getImageByName(FarmItem.ICON_FEED);
                  if(iconUrl == null)
                  {
                     iconUrl = this.m_reward.iconUrl;
                  }
               }
               addWidget(new FarmIcon(m_window["icon_mc"],iconUrl));
            }
            else if(m_window.hasOwnProperty("opf_mc"))
            {
               this.addWidget(new ObjectPreviewFrame(m_window.opf_mc,this.m_reward,null,[this.m_zoomingScale],null,"","",null,new Point(0,OFFSET_OPF_Y)));
            }
         }
      }
      
      public function onButtonClick(event:Event) : void
      {
         this.close();
         AFInnovationManager.getInstance().mainWindow.untintWindow();
         AFInnovationManager.getInstance().mainWindow.refreshWindow();
         AFInnovationManager.getInstance().mainWindow.enableInput = true;
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         if(m_closeButton)
         {
            m_closeButton.visible = false;
         }
      }
   }
}

