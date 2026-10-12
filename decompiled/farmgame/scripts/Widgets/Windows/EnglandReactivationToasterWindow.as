package Widgets.Windows
{
   import Classes.util.ZLocUtils;
   import Display.FarmDynamicDialog;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import com.troyer.widget.view.TextFieldView;
   import flash.events.MouseEvent;
   
   public class EnglandReactivationToasterWindow extends ToasterWindow
   {
      
      private static const ASSET_PATH:String = "assets/dialogs/FV_BannerAd_xpromo_genericAlt.swf";
      
      protected static const POPUP_NAME:String = "EnglandReactivationToaster";
      
      protected var m_message:String;
      
      protected var m_title:String;
      
      protected var m_bgPath:String;
      
      private var m_shouldPopInfo:Boolean = false;
      
      public function EnglandReactivationToasterWindow(message:String, title:String = "", bgPath:String = "", shouldPopInfo:Boolean = false)
      {
         super(ASSET_PATH);
         this.name = POPUP_NAME;
         this.m_message = message;
         this.m_title = title;
         this.m_bgPath = bgPath;
         this.m_shouldPopInfo = shouldPopInfo;
      }
      
      override protected function postLoadComplete() : void
      {
         var bg_mc:FarmIcon = null;
         if(null != m_window.title_tf && "" != this.m_title)
         {
            addWidget(new ZwTextField(m_window.title_tf,this.m_title));
         }
         addWidget(new ZwTextField(m_window.message_tf,this.m_message));
         addWidget(new ZwButton(m_window.hitbox_mc,this.onHitBoxClick));
         if(null != m_window.background_mc && "" != this.m_bgPath)
         {
            bg_mc = new FarmIcon(m_window.background_mc,this.m_bgPath);
            addWidget(bg_mc);
         }
      }
      
      protected function onHitBoxClick(event:MouseEvent) : void
      {
         var dialog:FarmDynamicDialog = null;
         if(event)
         {
            event.stopPropagation();
         }
         if(this.m_shouldPopInfo == true)
         {
            dialog = FarmDynamicDialog.createDialog("englandOnboardingLapsedUserInfo",FarmDynamicDialog);
            dialog.setShortcutAttribute("okayButton",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","Okay"));
            dialog.setup();
            dialog.show(true);
         }
         close();
      }
   }
}

