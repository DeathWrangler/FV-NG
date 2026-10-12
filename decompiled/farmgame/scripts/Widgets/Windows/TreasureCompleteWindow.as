package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.events.Event;
   
   public class TreasureCompleteWindow extends FarmWindow
   {
      
      private static const DIALOG_UTIL_PKG:String = "Dialogs";
      
      private static const TITLE_TEXT_POSTFIX:String = "_TitleText";
      
      private static const COPY_TEXT_POSTFIX:String = "_CopyText";
      
      private static const SUBCOPY_TEXT_POSTFIX:String = "_SubCopyText";
      
      private static const GIFTBOX_TEXT_POSTFIX:String = "_GiftboxText";
      
      private static const ACCEPTBUTTON_TEXT_POSTFIX:String = "_AcceptButtonText";
      
      private var m_treasureName:String = null;
      
      private var m_giftItemName:String = null;
      
      public function TreasureCompleteWindow(windowAsset:String, treasureName:String, transformData:Object = null)
      {
         super(windowAsset);
         this.m_treasureName = treasureName;
         if(transformData)
         {
            if(transformData.hasOwnProperty("gift"))
            {
               this.m_giftItemName = transformData.gift;
            }
         }
      }
      
      override protected function postLoadComplete() : void
      {
         var titleKey:String = null;
         var copyKey:String = null;
         var subcopyKey:String = null;
         var giftboxKey:String = null;
         var acceptButtonKey:String = null;
         if(m_window["title_tf"])
         {
            titleKey = this.keyHelperFunction(TITLE_TEXT_POSTFIX);
            addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t_pk(DIALOG_UTIL_PKG,titleKey)),true);
         }
         var giftItem:FarmItem = null;
         var giftFriendlyName:String = null;
         if(this.m_giftItemName != null)
         {
            giftItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_giftItemName);
            giftFriendlyName = ZLocUtils.tk_pk_asTitle(giftItem.friendlyName);
            if(m_window["icon_mc"])
            {
               addWidget(new FarmIcon(m_window.icon_mc,giftItem.iconUrl),true);
            }
         }
         if(m_window["copy_tf"])
         {
            copyKey = this.keyHelperFunction(COPY_TEXT_POSTFIX);
            addWidget(new ZwTextField(m_window.copy_tf,ZLocUtils.t_pk(DIALOG_UTIL_PKG,copyKey,{"giftName":giftFriendlyName})),true);
         }
         if(m_window["subcopy_tf"])
         {
            subcopyKey = this.keyHelperFunction(SUBCOPY_TEXT_POSTFIX);
            addWidget(new ZwTextField(m_window.subcopy_tf,ZLocUtils.t_pk(DIALOG_UTIL_PKG,subcopyKey,{"giftName":giftFriendlyName})),true);
         }
         if(m_window["giftbox_tf"])
         {
            giftboxKey = this.keyHelperFunction(GIFTBOX_TEXT_POSTFIX);
            addWidget(new ZwTextField(m_window.giftbox_tf,ZLocUtils.t_pk(DIALOG_UTIL_PKG,giftboxKey,{"giftName":giftFriendlyName})),true);
         }
         if(m_window["accept_bt"])
         {
            acceptButtonKey = this.keyHelperFunction(ACCEPTBUTTON_TEXT_POSTFIX);
            addWidget(new FarmAnimatedTextButton(m_window.accept_bt,ZLocUtils.t_pk(DIALOG_UTIL_PKG,acceptButtonKey),this.onAccept),true);
         }
         if(m_window["animation_mc"])
         {
            m_window.animation_mc.visible = true;
            m_window.animation_mc.gotoAndPlay(2);
         }
      }
      
      private function keyHelperFunction(postfix:String) : String
      {
         var result:String = "TreasureComplete" + postfix;
         if(ZLocUtils.hasString(DIALOG_UTIL_PKG,this.m_treasureName + postfix))
         {
            result = this.m_treasureName + postfix;
         }
         else if(this.m_giftItemName != null && ZLocUtils.hasString(DIALOG_UTIL_PKG,this.m_giftItemName + postfix))
         {
            result = this.m_giftItemName + postfix;
         }
         return result;
      }
      
      private function onAccept(event:Event) : void
      {
         close();
      }
   }
}

