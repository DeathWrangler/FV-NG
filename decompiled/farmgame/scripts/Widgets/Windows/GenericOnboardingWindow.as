package Widgets.Windows
{
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class GenericOnboardingWindow extends FarmWindow
   {
      
      private var m_cancelCallback:Function;
      
      private var m_acceptCallback:Function;
      
      private var m_params:Object;
      
      public function GenericOnboardingWindow(params:Object, acceptCallback:Function = null, cancelCallback:Function = null)
      {
         super(params["dialog"]);
         this.m_acceptCallback = acceptCallback;
         this.m_cancelCallback = cancelCallback;
         this.m_params = params;
      }
      
      override protected function postLoadComplete() : void
      {
         addWidget(new ZwBaseWidget(m_window.mainWindow));
         addWidget(new FarmAnimatedTextButton(m_window.mainWindow.accept_bt,ZLocUtils.t_pk(this.m_params["buttonText"]),this.onAccept));
         addWidget(new FarmTextField(m_window.mainWindow.body_tf,ZLocUtils.t_pk(this.m_params["text"])));
         if(Boolean(m_window.mainWindow.hasOwnProperty("icon_mc")) && this.m_params.hasOwnProperty("icon"))
         {
            addWidget(new FarmIcon(m_window.mainWindow.icon_mc,this.m_params["icon"]));
         }
         if(Boolean(m_window.mainWindow.hasOwnProperty("close_btn")) && Boolean(m_window.mainWindow.close_btn))
         {
            m_window.mainWindow.close_btn.addEventListener(MouseEvent.CLICK,this.onCancel);
         }
      }
      
      private function onAccept(event:MouseEvent) : void
      {
         if(this.m_acceptCallback !== null)
         {
            this.m_acceptCallback.call();
         }
         this.close();
      }
      
      private function onCancel(event:MouseEvent) : void
      {
         m_window.mainWindow.close_btn.removeEventListener(MouseEvent.CLICK,this.onCancel);
         if(this.m_cancelCallback !== null)
         {
            this.m_cancelCallback.call();
         }
         this.close();
      }
      
      override protected function onClose(event:Event) : void
      {
         if(this.m_cancelCallback !== null)
         {
            this.m_cancelCallback.call();
         }
         super.onClose(event);
      }
   }
}

