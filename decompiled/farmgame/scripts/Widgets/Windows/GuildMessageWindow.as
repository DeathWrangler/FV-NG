package Widgets.Windows
{
   import Managers.GuildEventManager;
   import Managers.GuildManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.Event;
   
   public class GuildMessageWindow extends FarmWindow
   {
      
      private var m_featureName:String;
      
      private var m_message:String;
      
      private var m_MessageTf:ZwTextField;
      
      private var m_okay_bt:FarmAnimatedTextButton;
      
      private var m_closeHandler:Function;
      
      private var m_title:String;
      
      private var m_titleTf:ZwTextField;
      
      private var m_fromSelect:Boolean;
      
      public function GuildMessageWindow(featureName:String = null, assetPath:String = "", message:String = "", closeHandler:Function = null, title:String = null, fromSelect:Boolean = false)
      {
         this.m_featureName = featureName;
         this.m_message = message;
         this.m_title = title;
         this.m_closeHandler = closeHandler;
         this.m_fromSelect = fromSelect;
         super(assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("title_tf"))
         {
            this.m_titleTf = new ZwTextField(m_window["title_tf"]);
            if(this.m_title != null)
            {
               this.m_titleTf.text = this.m_title;
               this.m_titleTf.visible = true;
            }
            else
            {
               this.m_titleTf.visible = false;
            }
         }
         if(m_window.hasOwnProperty("message_tf"))
         {
            this.m_MessageTf = new ZwTextField(m_window["message_tf"]);
            this.m_MessageTf.text = this.m_message;
            this.m_MessageTf.visible = true;
         }
         if(m_window.hasOwnProperty("okay_bt"))
         {
            addWidget(this.m_okay_bt = new FarmAnimatedTextButton(m_window["okay_bt"],"Okay!",this.onClose));
         }
      }
      
      private function get eventManager() : GuildEventManager
      {
         return GuildEventManager.getInstance();
      }
      
      private function get manager() : GuildManager
      {
         return GuildManager.getInstance();
      }
      
      override protected function onClose(evt:Event) : void
      {
         if(this.eventManager.m_orderSelectionWindow)
         {
            this.eventManager.m_orderSelectionWindow.untintWindow();
            this.eventManager.m_orderSelectionWindow.enableInput = true;
         }
         if(this.eventManager.m_guildEventMainWindow)
         {
            this.eventManager.m_guildEventMainWindow.m_overlayMc.visible = false;
         }
         if(this.m_fromSelect == false)
         {
            if(this.eventManager.m_guildEventMainWindow)
            {
               this.eventManager.m_guildEventMainWindow.untintWindow();
               this.eventManager.m_guildEventMainWindow.enableInput = true;
            }
         }
         if(this.m_closeHandler != null)
         {
            this.m_closeHandler(evt);
         }
         super.onClose(evt);
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         if(m_closeButton)
         {
            m_closeButton.visible = false;
         }
      }
      
      override public function close() : void
      {
         if(this.eventManager.m_orderSelectionWindow)
         {
            this.eventManager.m_orderSelectionWindow.untintWindow();
            this.eventManager.m_orderSelectionWindow.enableInput = true;
         }
         if(this.eventManager.m_guildEventMainWindow)
         {
            this.eventManager.m_guildEventMainWindow.m_overlayMc.visible = false;
         }
         if(this.m_fromSelect == false)
         {
            if(this.eventManager.m_guildEventMainWindow)
            {
               this.eventManager.m_guildEventMainWindow.untintWindow();
               this.eventManager.m_guildEventMainWindow.enableInput = true;
            }
         }
         super.close();
      }
   }
}

