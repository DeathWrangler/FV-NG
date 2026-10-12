package Widgets.Windows.NeighborVisit
{
   import Classes.Avatar.FarmAvatar;
   import Classes.FarmvilleClothingLoader;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import MyLife.NPC.SimpleNPC;
   import Transactions.TAddCommunityFriend;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.FarmWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class AddCommunityNeighborWindow extends FarmWindow
   {
      
      private static const AVATAR_SCALE:Number = 1;
      
      private var m_visitedUserId:String = "";
      
      private var m_visitedUserName:String = "";
      
      private var m_visitedAvatar:FarmAvatar = null;
      
      private var m_character:SimpleNPC = null;
      
      public function AddCommunityNeighborWindow(visitedUserId:String, visitedUserName:String, visitedAvatar:FarmAvatar)
      {
         super("assets/dialogs/FV_helpfriend.swf");
         this.m_visitedUserId = visitedUserId;
         this.m_visitedUserName = visitedUserName;
         this.m_visitedAvatar = visitedAvatar;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         var mainFrame:ZwFrame = addWidget(new ZwFrame(m_window.helpfriend_mc)) as ZwFrame;
         mainFrame.addWidget(new FarmButton(m_window.helpfriend_mc.close_bt,this.onClose));
         mainFrame.addWidget(new FarmAnimatedTextButton(m_window.helpfriend_mc.accept_bt,ZLocUtils.t("Dialogs","Accept"),this.onAcceptClick));
         mainFrame.addWidget(new ZwTextField(m_window.helpfriend_mc.playerName_tf,this.m_visitedUserName));
         mainFrame.addWidget(new ZwTextField(m_window.helpfriend_mc.greeting_tf,ZLocUtils.t("FarmVille","CommunityNeighbors_VisitWindow_AddNeighborPrompt",{"firstname":Global.player.firstName})));
         var characterContainer:ZwWidget = addWidget(new ZwWidget(m_window.helpfriend_mc.avatar_mc)) as ZwWidget;
         this.m_character = new SimpleNPC(new FarmvilleClothingLoader());
         this.m_character.setAvatarCustomizationData(this.m_visitedAvatar.getAvatarCustomizationData());
         this.m_character.x = 60;
         this.m_character.y = 160;
         this.m_character.scaleX = this.m_character.scaleY = AVATAR_SCALE;
         (characterContainer.element as MovieClip).addChild(this.m_character);
      }
      
      private function onAcceptClick(event:Event) : void
      {
         TransactionManager.addTransaction(new TAddCommunityFriend(this.m_visitedUserId),true);
         close();
      }
      
      override protected function onClose(event:Event) : void
      {
         close();
      }
      
      override protected function release() : void
      {
         this.m_character.parent.removeChild(this.m_character);
         this.m_character = null;
         this.m_visitedAvatar = null;
         super.release();
      }
   }
}

