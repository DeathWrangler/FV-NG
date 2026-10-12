package Classes
{
   import Classes.Avatar.FarmAvatar;
   import Classes.util.ZLocUtils;
   import Display.MessageCenterDialog;
   import Display.UI;
   import Engine.Constants;
   import Engine.Managers.LoadingManager;
   import Managers.FarmStatsManager;
   import Managers.MessageManager;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   
   public class MessageAvatar extends FarmAvatar
   {
      
      private var m_messageId:int;
      
      private var m_speechBubbleLoader:Loader;
      
      private var m_speechBubble:MovieClip = null;
      
      public function MessageAvatar(messageId:int, customizationData:Object = null)
      {
         super(customizationData);
         m_depthPriority = 100;
         m_objectType = Constants.WORLDOBJECT_MESSAGE_SIGN;
         this.m_messageId = messageId;
         this.m_speechBubbleLoader = LoadingManager.load(Global.getAssetURL("assets/dialogs/FV_Message_SpeechBubble.swf"),this.onLoadSpeechBubble);
      }
      
      override public function onClick() : void
      {
         var messageCenter:MessageCenterDialog = new MessageCenterDialog();
         UI.displayPopup(messageCenter);
         if(Global.worldManager.isVisiting())
         {
            FarmStatsManager.count("Comment_box","comment_box_chatbubbles","friendfarm");
         }
         else
         {
            FarmStatsManager.count("Comment_box","comment_box_chatbubbles","selffarm");
         }
      }
      
      private function onFinishEmailPermissions() : void
      {
         if(GlobalEngine.socialNetwork.userHasEmailPermission())
         {
            UI.displayPopup(new MessageCenterDialog());
         }
      }
      
      private function onLoadSpeechBubble(event:Event) : void
      {
         var message:Message = null;
         var authorId:String = null;
         var userName:String = null;
         var userGender:String = null;
         var sprite:Sprite = null;
         this.m_speechBubble = this.m_speechBubbleLoader.content as MovieClip;
         if(this.m_speechBubble != null)
         {
            message = MessageManager.getInstance().getMessage(this.m_messageId);
            if(message)
            {
               authorId = message.getAuthorId();
               userName = MessageManager.getPlayerName(authorId,false);
               userGender = MessageManager.getPlayerGender(authorId);
               this.m_speechBubble.comment_tf.text = ZLocUtils.t("FarmGame","MessageSpeechBubble",{"user":ZLocUtils.tn(userName,ZLocUtils.tg(userGender))});
               this.m_speechBubble.visible = true;
               this.m_speechBubble.enabled = true;
               this.m_speechBubble.x = 15;
               this.m_speechBubble.y = -125;
               sprite = this.m_displayObject as Sprite;
               if(sprite)
               {
                  sprite.addChildAt(this.m_speechBubble,0);
               }
            }
         }
      }
      
      override public function detach() : void
      {
         if(this.m_speechBubble != null && this.m_speechBubble.parent != null)
         {
            if(this.m_speechBubble.parent is DisplayObject)
            {
               this.m_speechBubble.parent.removeChildAt(0);
               this.m_speechBubble = null;
            }
         }
         super.detach();
      }
      
      override public function conditionallyRedraw(forceRedraw:Boolean = false) : void
      {
      }
      
      override public function canBeClickedOnVisit() : Boolean
      {
         return true;
      }
   }
}

