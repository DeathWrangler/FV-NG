package Widgets.Windows
{
   import Classes.util.MovieClipUtils;
   import Display.UI;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class SeasonRewardWindow extends FarmWindow
   {
      
      protected static const ACCEPT_BUTTON_NAME:String = "accept_bt";
      
      protected var m_onOkCallback:Function = null;
      
      protected var m_worldType:String;
      
      protected var m_ftuePath:String;
      
      public function SeasonRewardWindow(dialogAsset:String, acceptCallback:Function = null, worldType:String = null, ftuePath:String = null)
      {
         super(dialogAsset,true,true);
         this.m_onOkCallback = acceptCallback;
         this.m_worldType = worldType;
         this.m_ftuePath = ftuePath;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         var okayButtonText:String = "Awesome!";
         if(m_window.hasOwnProperty("mainWindow"))
         {
            MovieClipUtils.recursivePlay(m_window);
            addWidget(new ZwBaseWidget(m_window.mainWindow));
            if(m_window.mainWindow[ACCEPT_BUTTON_NAME])
            {
               addWidget(new FarmAnimatedTextButton(m_window.mainWindow[ACCEPT_BUTTON_NAME],okayButtonText,this.onOkButtonClick));
            }
            if(m_window.mainWindow.whatisthis_mc)
            {
               if(this.m_ftuePath != null && this.m_ftuePath != "")
               {
                  addWidget(new FarmAnimatedButton(m_window.mainWindow.whatisthis_mc,this.FTUEClick));
               }
               else
               {
                  m_window.mainWindow.whatisthis_mc.visible = false;
               }
            }
         }
         m_window.visible = true;
      }
      
      protected function FTUEClick(e:Event) : void
      {
         UI.displayPopup(new MOTDTutorialWindow(this.m_ftuePath),false);
      }
      
      override protected function release() : void
      {
         this.m_onOkCallback = null;
         super.release();
      }
      
      private function onOkButtonClick(event:MouseEvent) : void
      {
         if(this.m_onOkCallback != null)
         {
            this.m_onOkCallback(this.m_worldType);
         }
         close();
      }
   }
}

