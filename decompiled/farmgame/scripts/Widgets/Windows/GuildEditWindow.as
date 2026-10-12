package Widgets.Windows
{
   import Display.GenericPopup;
   import Display.UI;
   import Managers.GuildManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.GuildLogoRequestFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   
   public class GuildEditWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 7;
      
      public static const ICON_SIZE:int = 50;
      
      private static const FEATURE_NAME:String = "FVGuild";
      
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
      
      private var m_logoFrame_mc:GuildLogoRequestFrame;
      
      private var m_guildInfo:Object;
      
      private var m_selectBt1:FarmButton;
      
      private var m_selectBt2:FarmButton;
      
      private var m_checkMark1:MovieClip;
      
      private var m_checkMark2:MovieClip;
      
      private var m_inviteStatus:String = "CLOSED";
      
      private var m_imageId:int = 0;
      
      private var m_icon:FarmIcon;
      
      private var m_canClearName:Boolean = true;
      
      private var m_canClearDes:Boolean = true;
      
      private var m_name_mc:*;
      
      private var m_des_mc:*;
      
      public function GuildEditWindow(featureName:String, assetUrl:String, guildInfo:Object)
      {
         this.m_featureName = featureName;
         this.m_guildInfo = guildInfo;
         var numOfTutorialPages:int = NUM_TUTORIAL_SCENES;
         super(FEATURE_NAME,assetUrl,numOfTutorialPages);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],"Edit Clan Details"));
         }
         if(m_window.hasOwnProperty("checkbox1_tf"))
         {
            this.m_checkbox1_tf = new ZwTextField(m_window["checkbox1_tf"],"Private");
            this.m_checkbox1_tf.visible = true;
            this.m_checkbox1_tf.attachTooltip(new FarmTextTooltip("Private mode doesn\'t allow outside players to join without prior permission. Leader, Co-Leader or General can accept requests from players to join clan."));
         }
         if(m_window.hasOwnProperty("checkbox2_tf"))
         {
            this.m_checkbox2_tf = new ZwTextField(m_window["checkbox2_tf"],"Public");
            this.m_checkbox2_tf.visible = true;
            this.m_checkbox2_tf.attachTooltip(new FarmTextTooltip("Public mode allows outside players to join without prior permission"));
         }
         if(m_window.hasOwnProperty("des_header_tf"))
         {
            this.m_des_header_tf = new ZwTextField(m_window["des_header_tf"],"Clan Description");
            this.m_des_header_tf.visible = true;
         }
         if(m_window.hasOwnProperty("des_tf"))
         {
            this.m_des_tf = new ZwTextField(m_window["des_tf"],this.m_guildInfo["description"]);
            this.m_des_tf.visible = true;
            this.m_des_mc = m_window["des_tf"];
         }
         if(m_window.hasOwnProperty("name_header_tf"))
         {
            this.m_name_header_tf = new ZwTextField(m_window["name_header_tf"],"Clan Name");
            this.m_name_header_tf.visible = true;
         }
         if(m_window.hasOwnProperty("privacy_header_tf"))
         {
            this.m_privacy_header_tf = new ZwTextField(m_window["privacy_header_tf"],"Clan Privacy");
            this.m_privacy_header_tf.visible = true;
         }
         if(m_window.hasOwnProperty("name_tf"))
         {
            this.m_name_tf = new ZwTextField(m_window["name_tf"],this.m_guildInfo["name"]);
            this.m_name_tf.visible = true;
            this.m_name_mc = m_window["name_tf"];
         }
         if(m_window.hasOwnProperty("pic_tf"))
         {
            this.m_pic_tf = new ZwTextField(m_window["pic_tf"],"Select New Pic");
            this.m_pic_tf.visible = true;
         }
         if(m_window.hasOwnProperty("okay_bt"))
         {
            addWidget(new FarmAnimatedTextButton(m_window["okay_bt"],"Save",this.onOkayClick));
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
            this.m_checkMark2.visible = false;
         }
         if(m_window.hasOwnProperty("pic_slots_mc"))
         {
            this.m_logoFrame_mc = new GuildLogoRequestFrame(m_window["pic_slots_mc"],this.m_featureName,this);
            this.m_logoFrame_mc.visible = true;
         }
         if(this.m_guildInfo["inviteStatus"])
         {
            this.m_checkMark1.visible = this.m_guildInfo["inviteStatus"] != "OPEN";
            this.m_checkMark2.visible = this.m_guildInfo["inviteStatus"] == "OPEN";
         }
         this.m_icon = new FarmIcon(m_window["pic_mc"] as MovieClip,GuildManager.GUILD_LOGO_IMAGE_ARRAY[int(this.m_guildInfo["alias"]) + 1]);
         this.m_icon.setIconSize(100,100);
         this.m_icon.visible = true;
         this.m_name_mc.addEventListener(MouseEvent.CLICK,this.switchOutFullScreen);
         this.m_des_mc.addEventListener(MouseEvent.CLICK,this.switchOutFullScreen);
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
      
      private function onOkayClick(e:Event) : void
      {
         var message:String = null;
         var name:String = this.m_name_tf.text;
         var des:String = this.m_des_tf.text;
         var imageId:int = this.m_imageId;
         var inviteStatus:String = this.m_inviteStatus;
         if(name == "" || des == "")
         {
            message = "Please fill the name and description properly...";
            UI.displayMessage(message,GenericPopup.TYPE_OK,null,"",true);
         }
         else
         {
            GuildManager.getInstance().editGuild(inviteStatus,name,des,imageId);
         }
      }
      
      private function clearNameFields() : Function
      {
         return function(evt:MouseEvent):void
         {
            if(m_canClearName)
            {
               m_name_tf.text = "";
               m_canClearName = false;
            }
         };
      }
      
      private function clearDesFields() : Function
      {
         return function(evt:MouseEvent):void
         {
            if(m_canClearDes)
            {
               m_des_tf.text = "";
               m_canClearDes = false;
            }
         };
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
      
      public function set imageId(index:int) : void
      {
         this.m_imageId = index;
         this.m_icon.loadIcon(GuildManager.GUILD_LOGO_IMAGE_ARRAY[index + 1]);
      }
      
      override public function close() : void
      {
         GuildManager.getInstance().m_guildEditWindow = null;
         super.close();
      }
      
      override protected function onClose(event:Event) : void
      {
         super.onClose(event);
         GuildManager.getInstance().openGuildViewWindow();
      }
      
      public function clearHighlight() : void
      {
         this.m_logoFrame_mc.clearHighlights();
      }
      
      public function switchOutFullScreen(e:Event) : void
      {
         Global.farmGame.switchOutFullScreen();
      }
   }
}

