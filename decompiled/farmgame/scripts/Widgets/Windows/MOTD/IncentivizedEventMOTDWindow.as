package Widgets.Windows.MOTD
{
   import Classes.util.ZLocUtils;
   import Managers.IncentivizedEventsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class IncentivizedEventMOTDWindow extends CustomWindowMOTDBase
   {
      
      private static const ASSET_URL_FALLBACK:String = "assets/dialogs/FV_motd_cybermonday2013_fbinvite.swf";
      
      protected var m_windowParams:Object = null;
      
      public function IncentivizedEventMOTDWindow(windowParams:Object = null)
      {
         var assetURL:String = ASSET_URL_FALLBACK;
         this.m_windowParams = windowParams;
         if(this.m_windowParams != null && this.m_windowParams.hasOwnProperty("dialog"))
         {
            assetURL = this.m_windowParams["dialog"];
         }
         super(assetURL);
      }
      
      private function recursivelyPlay(container:DisplayObjectContainer) : void
      {
         var displayContainer:DisplayObjectContainer = null;
         if(container is MovieClip)
         {
            MovieClip(container).play();
         }
         for(var childIdx:int = 0; childIdx < container.numChildren; childIdx++)
         {
            displayContainer = container.getChildAt(childIdx) as DisplayObjectContainer;
            if(Boolean(displayContainer) && displayContainer.numChildren > 1)
            {
               this.recursivelyPlay(displayContainer);
            }
         }
      }
      
      override protected function postLoadComplete() : void
      {
         var dialogPrefix:String = null;
         var mainWindow:ZwFrame = null;
         var titleText:String = null;
         var bodyText1:String = null;
         var bodyText2:String = null;
         var bodyText3:String = null;
         var buttonText:String = null;
         super.postLoadComplete();
         if(m_window.mainWindow)
         {
            dialogPrefix = IncentivizedEventsManager.instance.dialogPrefix;
            mainWindow = addWidget(new ZwFrame(m_window.mainWindow)) as ZwFrame;
            titleText = ZLocUtils.t("Dialogs","MOTD_" + dialogPrefix + "_invite_title");
            bodyText1 = ZLocUtils.t("Dialogs","MOTD_" + dialogPrefix + "_invite_body1");
            bodyText2 = ZLocUtils.t("Dialogs","MOTD_" + dialogPrefix + "_invite_body2");
            bodyText3 = ZLocUtils.t("Dialogs","MOTD_" + dialogPrefix + "_invite_body3");
            buttonText = ZLocUtils.t("Dialogs","MOTD_" + dialogPrefix + "_invite_button");
            mainWindow.addWidget(new ZwTextField(m_window.mainWindow.title_tf,titleText));
            if(m_window.mainWindow["body_tf"])
            {
               mainWindow.addWidget(new ZwTextField(m_window.mainWindow.body_tf,bodyText1));
            }
            if(m_window.mainWindow["body2_tf"])
            {
               mainWindow.addWidget(new ZwTextField(m_window.mainWindow.body2_tf,bodyText2));
            }
            if(m_window.mainWindow["body3_tf"])
            {
               mainWindow.addWidget(new ZwTextField(m_window.mainWindow.body3_tf,bodyText3));
            }
            mainWindow.addWidget(new FarmAnimatedTextButton(m_window.mainWindow.accept_bt,buttonText,this.onClickJoin));
            if(m_window.mainWindow["close_bt"])
            {
               m_closeButton = addWidget(new FarmButton(m_window.mainWindow.close_bt,this.onClose)) as FarmButton;
            }
            this.recursivelyPlay(m_window.mainWindow);
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         super.onClose(event);
      }
      
      private function onClickJoinAndShare(event:MouseEvent) : void
      {
         IncentivizedEventsManager.instance.rsvpAndShareEvent(true);
         this.onClose(event);
      }
      
      private function onClickJoin(event:MouseEvent) : void
      {
         IncentivizedEventsManager.instance.rsvpAndShareEvent(false);
         this.onClose(event);
      }
      
      private function onClickAwesome(event:MouseEvent) : void
      {
         this.onClose(event);
      }
   }
}

