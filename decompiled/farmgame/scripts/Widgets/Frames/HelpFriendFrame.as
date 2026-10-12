package Widgets.Frames
{
   import Classes.Friend;
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestManager;
   import Classes.util.ZLocUtils;
   import Engine.Utilities;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   
   public class HelpFriendFrame extends ZwFrame
   {
      
      protected var m_helpClickCallback:Function;
      
      protected var m_friend:Friend;
      
      protected var m_iconFalse:FarmIcon;
      
      protected var m_textFalse:ZwTextField;
      
      protected var m_iconTrue:FarmIcon;
      
      protected var m_textTrue:ZwTextField;
      
      protected var m_buttonTrue:FarmAnimatedTextButton;
      
      protected var m_elementTrue:MovieClip;
      
      protected var m_elementFalse:MovieClip;
      
      protected var m_questChain:String = "";
      
      protected var m_playerQuest:FarmQuest = null;
      
      public function HelpFriendFrame(elementTrue:MovieClip, elementFalse:MovieClip, helpClickCallback:Function)
      {
         var sprite:Sprite = new Sprite();
         sprite.addChild(elementTrue);
         sprite.addChild(elementFalse);
         super(sprite);
         this.m_elementTrue = elementTrue;
         this.m_elementFalse = elementFalse;
         this.m_helpClickCallback = helpClickCallback;
         if(this.m_elementTrue.picTrue_mc)
         {
            this.m_iconTrue = new FarmIcon(this.m_elementTrue.picTrue_mc,"");
            addWidget(this.m_iconTrue);
         }
         if(this.m_elementTrue.genericTrue_tf)
         {
            this.m_textTrue = new ZwTextField(this.m_elementTrue.genericTrue_tf,"");
            addWidget(this.m_textTrue);
         }
         if(this.m_elementTrue.help_bt)
         {
            this.m_buttonTrue = new FarmAnimatedTextButton(this.m_elementTrue.help_bt,"",this.onHelpClick);
            addWidget(this.m_buttonTrue);
         }
         if(this.m_elementFalse.picFalse_mc)
         {
            this.m_iconFalse = new FarmIcon(this.m_elementFalse.picFalse_mc,"");
            addWidget(this.m_iconFalse);
         }
         if(this.m_elementFalse.genericFalse_tf)
         {
            this.m_textFalse = new ZwTextField(this.m_elementFalse.genericFalse_tf,"");
            addWidget(this.m_textFalse);
         }
      }
      
      public function setFriend(friend:Friend, isInteractive:Boolean, text:String, buttonText:String = "") : void
      {
         this.m_friend = friend;
         if(isInteractive)
         {
            Utilities.toggleInputAndChildren(m_element as Sprite,true);
            this.m_elementFalse.visible = false;
            Utilities.toggleInputAndChildren(this.m_elementFalse,false);
            this.m_elementTrue.visible = true;
            Utilities.toggleInputAndChildren(this.m_elementTrue,true);
            if(this.m_iconTrue)
            {
               this.m_iconTrue.loadIcon(this.m_friend.picture);
            }
            if(this.m_buttonTrue)
            {
               this.m_buttonTrue.text = buttonText;
            }
            if(this.m_textTrue)
            {
               this.m_textTrue.text = text;
            }
         }
         else
         {
            this.m_elementTrue.visible = false;
            Utilities.toggleInputAndChildren(this.m_elementTrue,false);
            this.m_elementFalse.visible = true;
            Utilities.toggleInputAndChildren(this.m_elementFalse,true);
            if(this.m_iconFalse)
            {
               this.m_iconFalse.loadIcon(this.m_friend.picture);
            }
            if(this.m_textFalse)
            {
               this.m_textFalse.text = text;
            }
         }
      }
      
      public function getFriend() : Friend
      {
         return this.m_friend;
      }
      
      protected function onHelpClick(event:MouseEvent) : void
      {
         this.m_helpClickCallback(this.m_friend);
         if(this.m_questChain != "")
         {
            this.setupForQuestHelp(this.m_friend,this.m_questChain,this.m_playerQuest);
         }
      }
      
      public function setupForQuestHelp(friend:Friend, questChain:String, playerQuest:FarmQuest) : void
      {
         var buttonText:String = "";
         var fieldText:String = "";
         this.m_questChain = questChain;
         this.m_playerQuest = playerQuest;
         var canHelp:int = friend.canHelp(questChain,playerQuest);
         var interactive:Boolean = false;
         switch(canHelp)
         {
            case FarmQuestManager.CAN_HELP:
               interactive = true;
               fieldText = friend.name;
               buttonText = ZLocUtils.t("Dialogs","HelpFriendFrame_Ask");
               break;
            case FarmQuestManager.CANT_HELP:
               fieldText = ZLocUtils.t("Dialogs","HelpFriendFrame_AskHelp_No",{"user":ZLocUtils.tn(friend.name,ZLocUtils.tg(friend.snUser.gender))});
               break;
            case FarmQuestManager.WAIT_HELP:
               fieldText = ZLocUtils.t("Dialogs","HelpFriendFrame_AskHelp_Time",{"user":ZLocUtils.tn(friend.name,ZLocUtils.tg(friend.snUser.gender))});
               break;
            case FarmQuestManager.CAN_SEND:
               interactive = true;
               fieldText = friend.name;
               buttonText = ZLocUtils.t("Dialogs","HelpFriendFrame_Send");
               break;
            case FarmQuestManager.CANT_SEND:
               fieldText = ZLocUtils.t("Dialogs","HelpFriendFrame_SendHelp_No",{"user":ZLocUtils.tn(friend.name,ZLocUtils.tg(friend.snUser.gender))});
               break;
            case FarmQuestManager.WAIT_SEND:
               fieldText = ZLocUtils.t("Dialogs","HelpFriendFrame_SendHelp_Time",{"user":ZLocUtils.tn(friend.name,ZLocUtils.tg(friend.snUser.gender))});
         }
         this.setFriend(friend,interactive,fieldText,buttonText);
      }
   }
}

