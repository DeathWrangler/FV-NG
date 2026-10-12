package Display.HUD
{
   import Classes.Constants.Experiments;
   import Display.FriendBar.FriendBarSlot;
   import Engine.Managers.LoadingManager;
   import Events.OnlineStatusEvent;
   import Managers.ChatManager;
   import Managers.FarmStatsManager;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class ChatMessageNotification extends Sprite
   {
      
      private static const ASSET_SWF_URL_AGGRESSIVE:String = "assets/hud/FV_Message.swf";
      
      private static const ASSET_SWF_URL_NON_AGGRESSIVE:String = "assets/hud/FV_Message2.swf";
      
      private var m_rootAsset:MovieClip = null;
      
      private var m_statusIcon:MovieClip = null;
      
      private var m_messageBubbleBtn:MovieClip = null;
      
      private var m_newMessageNumber:TextField = null;
      
      private var m_newMessageCount:int = 0;
      
      private var m_newMessageAnimPlaying:Boolean = false;
      
      private var m_flyoutAnim:MovieClip = null;
      
      private var m_playAnimationOnLoad:Boolean = false;
      
      private var m_useAggressiveSurfacing:Boolean = false;
      
      private var m_bubbleButtonReturnState:int = 1;
      
      public function ChatMessageNotification()
      {
         super();
         this.m_useAggressiveSurfacing = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_JEWEL_PULSE) > 1;
         LoadingManager.load(Global.getAssetURL(this.m_useAggressiveSurfacing ? ASSET_SWF_URL_AGGRESSIVE : ASSET_SWF_URL_NON_AGGRESSIVE),this.onAssetLoaded);
         ChatManager.instance.addEventListener(OnlineStatusEvent.STATUS_CHANGE,this.onUserStatusChange);
         ChatManager.instance.addEventListener(ChatManager.EVENTTYPE_CHAT_WINDOW_OPEN,this.onChatWindowOpen);
      }
      
      private function onAssetLoaded(event:Event) : void
      {
         var assetLoader:Loader = event.target.loader as Loader;
         if(assetLoader != null)
         {
            this.m_rootAsset = assetLoader.content as MovieClip;
            this.m_statusIcon = this.m_rootAsset.status_mc;
            this.m_newMessageNumber = this.m_rootAsset.number_tf;
            this.m_newMessageNumber.text = "";
            this.m_newMessageNumber.addEventListener(MouseEvent.ROLL_OUT,this.onButtonOut);
            this.m_newMessageNumber.addEventListener(MouseEvent.ROLL_OVER,this.onButtonOver);
            this.m_newMessageNumber.addEventListener(MouseEvent.MOUSE_DOWN,this.onButtonDown);
            this.m_newMessageNumber.addEventListener(MouseEvent.MOUSE_UP,this.onButtonUp);
            this.m_messageBubbleBtn = this.m_rootAsset.chatBubble_mc;
            this.m_messageBubbleBtn.gotoAndStop(1);
            this.m_messageBubbleBtn.buttonMode = true;
            this.m_messageBubbleBtn.addEventListener(MouseEvent.ROLL_OUT,this.onButtonOut);
            this.m_messageBubbleBtn.addEventListener(MouseEvent.ROLL_OVER,this.onButtonOver);
            this.m_messageBubbleBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onButtonDown);
            this.m_messageBubbleBtn.addEventListener(MouseEvent.MOUSE_UP,this.onButtonUp);
            this.m_flyoutAnim = this.m_rootAsset.msgAnimation_mc;
            if(this.m_playAnimationOnLoad)
            {
               this.playFlyoutAnimation();
            }
            else
            {
               this.m_flyoutAnim.gotoAndStop(1);
            }
            addChild(this.m_rootAsset);
            this.refreshJewelState();
         }
      }
      
      private function onUserStatusChange(event:OnlineStatusEvent) : void
      {
         if(event.status == OnlineStatusEvent.NEW_MESSAGE && event.message.type == ChatManager.EVENTTYPE_CHAT && event.friendUid != ChatManager.currentChatWindowOpen)
         {
            this.refreshJewelState();
            if(!this.m_newMessageAnimPlaying && this.m_newMessageCount > 0)
            {
               if(this.m_rootAsset != null)
               {
                  this.playFlyoutAnimation();
               }
               else
               {
                  this.m_playAnimationOnLoad = true;
               }
            }
         }
      }
      
      private function playFlyoutAnimation() : void
      {
         this.m_flyoutAnim.addEventListener(Event.ENTER_FRAME,this.onFlyoutEnterFrame);
         this.m_flyoutAnim.gotoAndPlay(1);
         this.m_newMessageAnimPlaying = true;
         if(this.m_useAggressiveSurfacing)
         {
            this.m_messageBubbleBtn.gotoAndPlay("pulse");
            this.m_messageBubbleBtn.addEventListener(Event.ENTER_FRAME,this.onPulseEnterFrame);
         }
      }
      
      private function onChatWindowOpen(event:Event) : void
      {
         this.refreshJewelState();
      }
      
      private function refreshJewelState() : void
      {
         this.m_newMessageCount = ChatManager.getNumUnreadConversations();
         if(this.m_rootAsset != null)
         {
            this.m_newMessageNumber.text = this.m_newMessageCount.toString();
            if(this.m_newMessageCount > 0)
            {
               this.m_statusIcon.gotoAndStop(2);
               this.m_newMessageNumber.visible = true;
               this.visible = true;
            }
            else
            {
               this.visible = false;
               this.m_statusIcon.gotoAndStop(1);
               this.m_newMessageNumber.visible = false;
            }
         }
      }
      
      private function onFlyoutEnterFrame(event:Event) : void
      {
         if(this.m_flyoutAnim.currentFrame == this.m_flyoutAnim.totalFrames)
         {
            this.m_newMessageAnimPlaying = false;
            this.m_flyoutAnim.removeEventListener(Event.ENTER_FRAME,this.onFlyoutEnterFrame);
            this.m_flyoutAnim.gotoAndStop(1);
         }
      }
      
      private function onPulseEnterFrame(event:Event) : void
      {
         if(this.m_messageBubbleBtn.currentFrame == this.m_messageBubbleBtn.totalFrames)
         {
            this.m_messageBubbleBtn.removeEventListener(Event.ENTER_FRAME,this.onPulseEnterFrame);
            this.m_messageBubbleBtn.gotoAndStop(this.m_bubbleButtonReturnState);
         }
      }
      
      private function onButtonOut(event:MouseEvent) : void
      {
         if(this.m_useAggressiveSurfacing && this.m_newMessageAnimPlaying)
         {
            this.m_bubbleButtonReturnState = 1;
         }
         else
         {
            this.m_messageBubbleBtn.gotoAndStop(1);
         }
      }
      
      private function onButtonOver(event:MouseEvent) : void
      {
         if(this.m_useAggressiveSurfacing && this.m_newMessageAnimPlaying)
         {
            this.m_bubbleButtonReturnState = 2;
         }
         else
         {
            this.m_messageBubbleBtn.gotoAndStop(2);
         }
      }
      
      private function onButtonDown(event:MouseEvent) : void
      {
         if(this.m_useAggressiveSurfacing && this.m_newMessageAnimPlaying)
         {
            this.m_bubbleButtonReturnState = 3;
         }
         else
         {
            this.m_messageBubbleBtn.gotoAndStop(3);
         }
      }
      
      private function onButtonUp(event:MouseEvent) : void
      {
         var slot:FriendBarSlot = null;
         if(this.m_useAggressiveSurfacing && this.m_newMessageAnimPlaying)
         {
            this.m_bubbleButtonReturnState = 1;
         }
         else
         {
            this.m_messageBubbleBtn.gotoAndStop(1);
         }
         var friendSlots:Array = Global.ui.m_friendBar.slots;
         for(var slotIndex:* = int(friendSlots.length - 1); slotIndex >= 0; slotIndex--)
         {
            slot = friendSlots[slotIndex];
            if(!slot.m_empty && slot.messagingStatus == OnlineStatusEvent.NEW_MESSAGE)
            {
               FarmStatsManager.count("chat","clickjewel");
               event.stopImmediatePropagation();
               slot.openChatWindow();
               break;
            }
         }
      }
   }
}

