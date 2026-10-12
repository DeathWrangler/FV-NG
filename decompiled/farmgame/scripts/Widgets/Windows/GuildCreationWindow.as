package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.GuildEventManager;
   import Managers.GuildManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.GuildLogoRequestFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import mx.utils.StringUtil;
   
   public class GuildCreationWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 7;
      
      public static const ICON_SIZE:int = 50;
      
      private static const FEATURE_NAME:String = "FVGuild";
      
      private static const WINDOW_PREFIX:String = "guild_creation_";
      
      private var m_featureName:String = null;
      
      private const TITLE_TF:String = "title_tf";
      
      private var m_checkbox1_tf:ZwTextField;
      
      private var m_checkbox2_tf:ZwTextField;
      
      private var m_des_header_tf:ZwTextField;
      
      private var m_des_tf:ZwTextField;
      
      private var m_name_header_tf:ZwTextField;
      
      private var m_name_tf:ZwTextField;
      
      private var m_pic_tf:ZwTextField;
      
      private var m_privacy_header_tf:ZwTextField;
      
      private var m_createWithFV:Boolean = true;
      
      private var m_logoFrame_mc:GuildLogoRequestFrame;
      
      private var m_selectBt1:FarmButton;
      
      private var m_selectBt2:FarmButton;
      
      private var m_checkMark1:MovieClip;
      
      private var m_checkMark2:MovieClip;
      
      private var m_inviteStatus:String = "OPEN";
      
      private var m_imageId:int = 0;
      
      private var m_icon:FarmIcon;
      
      private var m_canClearName:Boolean = true;
      
      private var m_canClearDes:Boolean = true;
      
      private var m_name_mc:*;
      
      private var m_des_mc:*;
      
      private var m_createWithFCButton:FarmAnimatedCashButton;
      
      private var m_createWithoutFCButton:FarmAnimatedTextButton;
      
      private var m_closeButtonVisibility:Boolean;
      
      public function GuildCreationWindow(featureName:String = "FVGuild", assetUrl:String = null, withFV:Boolean = true, closeButtonVisibility:Boolean = true)
      {
         this.m_featureName = featureName;
         var numOfTutorialPages:int = NUM_TUTORIAL_SCENES;
         this.m_createWithFV = withFV;
         this.m_closeButtonVisibility = closeButtonVisibility;
         super(FEATURE_NAME,assetUrl,numOfTutorialPages);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,WINDOW_PREFIX + "title")));
         }
         if(m_window.hasOwnProperty("checkbox1_tf"))
         {
            this.m_checkbox1_tf = new ZwTextField(m_window["checkbox1_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,WINDOW_PREFIX + "privacy_private_text"));
            this.m_checkbox1_tf.visible = true;
            this.m_checkbox1_tf.attachTooltip(new FarmTextTooltip("Private mode doesn\'t allow outside players to join without prior permission. Leader, Co-Leader or General can accept requests from players to join clan."));
         }
         if(m_window.hasOwnProperty("checkbox2_tf"))
         {
            this.m_checkbox2_tf = new ZwTextField(m_window["checkbox2_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,WINDOW_PREFIX + "privacy_public_text"));
            this.m_checkbox2_tf.visible = true;
            this.m_checkbox2_tf.attachTooltip(new FarmTextTooltip("Public mode allows outside players to join without prior permission"));
         }
         if(m_window.hasOwnProperty("des_header_tf"))
         {
            this.m_des_header_tf = new ZwTextField(m_window["des_header_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,WINDOW_PREFIX + "description_header"));
            this.m_des_header_tf.visible = true;
         }
         if(m_window.hasOwnProperty("des_tf"))
         {
            this.m_des_tf = new ZwTextField(m_window["des_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,WINDOW_PREFIX + "description_default_text"));
            this.m_des_tf.visible = true;
            this.m_des_tf.alpha = 0.3;
            this.m_des_mc = m_window["des_tf"];
         }
         if(m_window.hasOwnProperty("name_header_tf"))
         {
            this.m_name_header_tf = new ZwTextField(m_window["name_header_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,WINDOW_PREFIX + "name_header"));
            this.m_name_header_tf.visible = true;
         }
         if(m_window.hasOwnProperty("privacy_header_tf"))
         {
            this.m_privacy_header_tf = new ZwTextField(m_window["privacy_header_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,WINDOW_PREFIX + "privacy_header"));
            this.m_privacy_header_tf.visible = true;
         }
         if(m_window.hasOwnProperty("name_tf"))
         {
            this.m_name_tf = new ZwTextField(m_window["name_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,WINDOW_PREFIX + "name_default_text"));
            this.m_name_tf.visible = true;
            this.m_name_tf.alpha = 0.3;
            this.m_name_mc = m_window["name_tf"];
         }
         if(m_window.hasOwnProperty("pic_tf"))
         {
            this.m_pic_tf = new ZwTextField(m_window["pic_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,WINDOW_PREFIX + "title"));
            this.m_pic_tf.visible = true;
         }
         if(m_window.hasOwnProperty("okay_bt"))
         {
            addWidget(this.m_createWithoutFCButton = new FarmAnimatedTextButton(m_window["okay_bt"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,WINDOW_PREFIX + "button_text"),this.onOkayClick));
            this.m_createWithoutFCButton.enabled = false;
         }
         if(m_window.hasOwnProperty("buy_bt"))
         {
            addWidget(this.m_createWithFCButton = new FarmAnimatedCashButton(m_window["buy_bt"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,WINDOW_PREFIX + "button_text"),"10",this.onOkayClick));
            this.m_createWithFCButton.enabled = false;
         }
         if(this.m_createWithFV)
         {
            this.m_createWithoutFCButton.visible = false;
            this.m_createWithFCButton.visible = true;
            FarmGameUtil.disableButtonAndShowTooltip(this.m_createWithFCButton,"Please fill all the required information to create clan");
            this.m_createWithFCButton.callback = null;
         }
         else
         {
            this.m_createWithoutFCButton.visible = true;
            this.m_createWithFCButton.visible = false;
            FarmGameUtil.disableButtonAndShowTooltip(this.m_createWithoutFCButton,"Please fill all the required information to create clan");
            this.m_createWithoutFCButton.callback = null;
         }
         if(m_window.hasOwnProperty("next_bt"))
         {
            addWidget(new FarmButton(m_window["next_bt"],this.onNextClick));
         }
         if(m_window.hasOwnProperty("back_bt"))
         {
            addWidget(new FarmButton(m_window["back_bt"],this.onBackClick));
         }
         if(m_window.hasOwnProperty("select1_bt"))
         {
            addWidget(this.m_selectBt1 = new FarmButton(m_window["select1_bt"],this.onSelect1Click));
            this.m_checkMark1 = m_window["select1_bt"]["mc_checkmark"] as MovieClip;
            this.m_checkMark1.visible = false;
         }
         if(m_window.hasOwnProperty("select2_bt"))
         {
            addWidget(this.m_selectBt2 = new FarmButton(m_window["select2_bt"],this.onSelect2Click));
            this.m_checkMark2 = m_window["select2_bt"]["mc_checkmark"] as MovieClip;
            this.m_checkMark2.visible = true;
         }
         if(m_window.hasOwnProperty("pic_slots_mc"))
         {
            this.m_logoFrame_mc = new GuildLogoRequestFrame(m_window["pic_slots_mc"],this.m_featureName,this);
            this.m_logoFrame_mc.visible = true;
         }
         var defaultImagePath:String = GuildManager.GUILD_LOGO_IMAGE_ARRAY[1];
         this.m_icon = new FarmIcon(m_window["pic_mc"] as MovieClip,defaultImagePath);
         this.m_icon.setIconSize(100,100);
         this.m_icon.visible = true;
         this.m_name_mc.addEventListener(MouseEvent.CLICK,this.clearNameFields());
         this.m_des_mc.addEventListener(MouseEvent.CLICK,this.clearDesFields());
         this.m_name_mc.addEventListener(KeyboardEvent.KEY_UP,this.checkNameLength);
         this.m_des_mc.addEventListener(KeyboardEvent.KEY_UP,this.checkDescriptionLength);
      }
      
      private function checkDescriptionLength(event:KeyboardEvent) : void
      {
         var msgString:String = this.m_des_tf.text;
         if(msgString.length > 45)
         {
            this.m_des_tf.text = msgString.substr(0,45);
         }
      }
      
      private function checkNameLength(event:KeyboardEvent) : void
      {
         var msgString:String = this.m_name_tf.text;
         if(msgString.length > 15)
         {
            this.m_name_tf.text = msgString.substr(0,15);
         }
      }
      
      private function clearNameFields() : Function
      {
         return function(evt:MouseEvent):void
         {
            Global.farmGame.switchOutFullScreen();
            if(m_canClearName)
            {
               m_name_tf.text = "";
               m_canClearName = false;
               m_name_tf.alpha = 1;
               if(!m_canClearName && !m_canClearDes)
               {
                  m_createWithoutFCButton.enabled = true;
                  m_createWithFCButton.enabled = true;
                  if(m_createWithFCButton.tooltip)
                  {
                     m_createWithFCButton.detachTooltip();
                  }
                  if(m_createWithoutFCButton.tooltip)
                  {
                     m_createWithoutFCButton.detachTooltip();
                  }
                  m_createWithoutFCButton.callback = null;
                  m_createWithFCButton.callback = null;
                  m_createWithoutFCButton.callback = onOkayClick;
                  m_createWithFCButton.callback = onOkayClick;
               }
            }
         };
      }
      
      private function clearDesFields() : Function
      {
         return function(evt:MouseEvent):void
         {
            Global.farmGame.switchOutFullScreen();
            if(m_canClearDes)
            {
               m_des_tf.text = "";
               m_des_tf.alpha = 1;
               m_canClearDes = false;
               if(!m_canClearName && !m_canClearDes)
               {
                  m_createWithoutFCButton.enabled = true;
                  m_createWithFCButton.enabled = true;
                  if(m_createWithFCButton.tooltip)
                  {
                     m_createWithFCButton.detachTooltip();
                  }
                  if(m_createWithoutFCButton.tooltip)
                  {
                     m_createWithoutFCButton.detachTooltip();
                  }
                  m_createWithoutFCButton.callback = null;
                  m_createWithFCButton.callback = null;
                  m_createWithoutFCButton.callback = onOkayClick;
                  m_createWithFCButton.callback = onOkayClick;
               }
            }
         };
      }
      
      private function onOkayClick(e:Event) : void
      {
         var message:String = null;
         var confText:String = null;
         var name:String = this.m_name_tf.text;
         var des:String = this.m_des_tf.text;
         var imageId:int = this.m_imageId;
         var inviteStatus:String = this.m_inviteStatus;
         var trimNameStr:String = StringUtil.trim(name);
         var trimDesStr:String = StringUtil.trim(des);
         var nameWhiteSpace:Boolean = !(Boolean(name) && name != "" && trimNameStr != "");
         var desWhiteSpace:Boolean = !(Boolean(des) && des != "" && trimDesStr != "");
         if(name == "" || des == "" || nameWhiteSpace || desWhiteSpace)
         {
            message = "Please fill all the required information to create a clan";
            GuildEventManager.getInstance().openGuildMessageWindow(message);
         }
         else if(this.m_createWithFV)
         {
            confText = "Are you sure to spend 10 FC to create a clan?";
            UI.displayMessage(confText,GenericPopup.TYPE_ACCEPTCANCEL,this.onAcceptCreateWithFC,"farmAnimatedTextConfirmation",true,true);
            tintWindow();
            enableInput = false;
         }
         else
         {
            GuildManager.getInstance().createGuild(inviteStatus,name,des,imageId.toString(),this.m_createWithFV);
         }
      }
      
      public function onAcceptCreateWithFC(event:GenericPopupEvent = null) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            GuildManager.getInstance().createGuild(this.m_inviteStatus,this.m_name_tf.text,this.m_des_tf.text,this.m_imageId.toString(),this.m_createWithFV);
         }
         untintWindow();
         enableInput = true;
      }
      
      private function onBackClick(e:Event) : void
      {
      }
      
      private function onNextClick(e:Event) : void
      {
      }
      
      private function onSelect1Click(e:Event) : void
      {
         this.m_checkMark2.visible = false;
         this.m_checkMark1.visible = true;
         this.m_inviteStatus = "CLOSED";
      }
      
      private function onSelect2Click(e:Event) : void
      {
         this.m_checkMark1.visible = false;
         this.m_checkMark2.visible = true;
         this.m_inviteStatus = "OPEN";
      }
      
      override public function close() : void
      {
         GuildManager.getInstance().m_guildCreateWindow = null;
         super.close();
      }
      
      public function set imageId(index:int) : void
      {
         this.m_imageId = index;
         this.m_icon.loadIcon(GuildManager.GUILD_LOGO_IMAGE_ARRAY[index + 1]);
      }
      
      override protected function onClose(event:Event) : void
      {
         super.onClose(event);
         GuildManager.getInstance().showUI();
      }
      
      public function clearHighlight() : void
      {
         this.m_logoFrame_mc.clearHighlights();
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         if(m_closeButton)
         {
            m_closeButton.visible = this.m_closeButtonVisibility;
         }
      }
      
      private function enableShortcut(event:FocusEvent) : void
      {
         Global.overrideDebugKeys = false;
      }
      
      private function disableShortcut(event:FocusEvent) : void
      {
         Global.overrideDebugKeys = true;
      }
   }
}

