package Widgets.Windows
{
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.events.Event;
   
   public class ThemedWindow extends FarmWindow
   {
      
      private static const DIALOG_ASSET:String = "assets/dialogs/FV_generic_xpromo.swf";
      
      private static const THEME_WIDTH:Number = 500;
      
      private static const THEME_HEIGHT:Number = 240;
      
      private static const ICON_SIZE:Number = 50;
      
      public static const BUTTON_SCHEME_ACCEPT_CANCEL:int = 0;
      
      public static const BUTTON_SCHEME_ACCEPT:int = 1;
      
      protected var m_buttonScheme:int = 0;
      
      protected var m_titleText:String = "";
      
      protected var m_topBodyText:String = "";
      
      protected var m_bottomBodyText:String = "";
      
      protected var m_acceptText:String = "";
      
      protected var m_cancelText:String = "";
      
      protected var m_themePath:String = "";
      
      protected var m_iconPath:String = "";
      
      protected var m_acceptCallback:Function = null;
      
      protected var m_cancelCallback:Function = null;
      
      public function ThemedWindow(buttonScheme:int = 0, modal:Boolean = true)
      {
         super(DIALOG_ASSET,modal);
         this.m_buttonScheme = buttonScheme;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new ZwFrame(m_window.bg_mc));
         addWidget(new ZwTextField(m_window.title_tf,this.m_titleText));
         var theme:FarmIcon = new FarmIcon(m_window.theme_mc,this.m_themePath);
         theme.setIconSize(THEME_WIDTH,THEME_HEIGHT);
         addWidget(theme);
         var icon:FarmIcon = new FarmIcon(m_window.icon_mc,this.m_iconPath);
         icon.setIconSize(ICON_SIZE,ICON_SIZE);
         addWidget(icon);
         addWidget(new ZwTextField(m_window.generic1_tf,this.m_topBodyText));
         addWidget(new ZwTextField(m_window.generic2_tf,this.m_bottomBodyText));
         switch(this.m_buttonScheme)
         {
            case BUTTON_SCHEME_ACCEPT_CANCEL:
               addWidget(new FarmAnimatedTextButton(m_window.visit_bt,this.m_acceptText,this.onAccept));
               addWidget(new FarmAnimatedTextButton(m_window.cancel_bt,this.m_cancelText,this.onCancel));
               break;
            case BUTTON_SCHEME_ACCEPT:
            default:
               addWidget(new FarmAnimatedTextButton(m_window.okay_bt,this.m_acceptText,this.onAccept));
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         this.onCancel(event);
      }
      
      public function onAccept(event:Event) : void
      {
         if(this.m_acceptCallback != null)
         {
            this.m_acceptCallback(event);
         }
         super.onClose(event);
      }
      
      public function onCancel(event:Event) : void
      {
         if(this.m_cancelCallback != null)
         {
            this.m_cancelCallback(event);
         }
         super.onClose(event);
      }
      
      public function setTitleText(text:String) : void
      {
         var title:ZwBaseWidget = null;
         if(m_window != null)
         {
            title = getWidget(m_window.title_tf);
            if(title != null)
            {
               (title as ZwTextField).text = text;
            }
         }
         this.m_titleText = text;
      }
      
      public function setBodyText(textTop:String, textBottom:String) : void
      {
         var top:ZwBaseWidget = null;
         var bottom:ZwBaseWidget = null;
         if(m_window != null)
         {
            top = getWidget(m_window.generic1_tf);
            if(top != null)
            {
               (top as ZwTextField).text = textTop;
            }
            bottom = getWidget(m_window.generic2_tf);
            if(bottom != null)
            {
               (bottom as ZwTextField).text = textBottom;
            }
         }
         this.m_bottomBodyText = textBottom;
         this.m_topBodyText = textTop;
      }
      
      public function setButtonText(textAccept:String, textCancel:String = "") : void
      {
         var accept:ZwBaseWidget = null;
         var cancel:ZwBaseWidget = null;
         if(m_window != null)
         {
            switch(this.m_buttonScheme)
            {
               case BUTTON_SCHEME_ACCEPT_CANCEL:
                  accept = getWidget(m_window.visit_bt);
                  if(accept != null)
                  {
                     (accept as FarmAnimatedTextButton).text = textAccept;
                  }
                  cancel = getWidget(m_window.cancel_bt);
                  if(cancel != null)
                  {
                     (cancel as FarmAnimatedTextButton).text = textCancel;
                  }
                  break;
               case BUTTON_SCHEME_ACCEPT:
               default:
                  accept = getWidget(m_window.okay_bt);
                  if(accept != null)
                  {
                     (accept as FarmAnimatedTextButton).text = textAccept;
                  }
            }
         }
         this.m_acceptText = textAccept;
         this.m_cancelText = textCancel;
      }
      
      public function setTheme(themeUrl:String) : void
      {
         var theme:ZwBaseWidget = null;
         if(m_window != null)
         {
            theme = getWidget(m_window.theme_mc);
            if(theme != null)
            {
               (theme as FarmIcon).loadIcon(themeUrl);
            }
         }
         this.m_themePath = themeUrl;
      }
      
      public function setIcon(iconUrl:String) : void
      {
         var icon:ZwBaseWidget = null;
         if(m_window != null)
         {
            icon = getWidget(m_window.icon_mc);
            if(icon != null)
            {
               (icon as FarmIcon).loadIcon(iconUrl);
            }
         }
         this.m_iconPath = iconUrl;
      }
      
      public function setAcceptCallback(callback:Function) : void
      {
         this.m_acceptCallback = callback;
      }
      
      public function setCancelCallback(callback:Function) : void
      {
         this.m_cancelCallback = callback;
      }
   }
}

