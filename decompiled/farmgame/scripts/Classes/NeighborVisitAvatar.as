package Classes
{
   import AvatarMode.AMNeighborWork;
   import Classes.Avatar.FriendAvatar;
   import Classes.NeighborActions.BaseNeighborAction;
   import Classes.NeighborActions.NeighborVisit;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.UI;
   import Engine.Classes.WorldObject;
   import Engine.Constants;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.StatsManager;
   import Managers.FarmStatsManager;
   import Managers.TrickOrTreatManager;
   import Widgets.Windows.NeighborVisit.AbstractRolloutWindow;
   import Widgets.Windows.NeighborVisit.FriendSuggestRollOutWindow;
   import Widgets.Windows.NeighborVisit.VisitBackRollOutWindow;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Loader;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.getQualifiedClassName;
   import gs.TweenLite;
   
   public class NeighborVisitAvatar extends FriendAvatar
   {
      
      protected static const MENU_ACCEPT:String = "neighborAvatarAccept";
      
      protected static const MENU_CANCEL:String = "neighborAvatarCancel";
      
      protected static const MENU_OKAY:String = "neighborAvatarOkay";
      
      protected static const TRICK_BACK:String = "neighborAvatarTrickBack";
      
      protected static const HIDE_ALL_ALT_GRAPHIC:String = "neighborAvatarHideAll";
      
      public static const NEIGHBOR_AVATAR_LAYER:String = "neighbor_avatar_layer";
      
      private static const FADE_OUT_TIME_IN_SEC:int = 2;
      
      private static const COLOR_HIGHLIGHT_YELLOW:uint = 16776960;
      
      private static const COLOR_HIGHLIGHT_GREEN:uint = 65280;
      
      public static const COLOR_HIGHLIGHT_ORANGE:uint = 14329120;
      
      protected var m_arrow:DisplayObject;
      
      private var m_neighborVisit:NeighborVisit;
      
      private var m_workedObjects:Array;
      
      private var m_neighborActions:Array;
      
      private var m_numTrickActions:int = 0;
      
      private var m_hangOnToWorkedObjectsHighlight:Boolean = false;
      
      private var m_neighborPicLoader:Loader;
      
      private var m_neighborPic:Bitmap = new Bitmap();
      
      private var m_neighborFrame:DisplayObject;
      
      private var m_picRolloutWindow:AbstractRolloutWindow;
      
      private var m_enableAvatarMouseEvents:Boolean = true;
      
      private const NEIGHBOR_PHOTO_X_SPACING:Number = 8;
      
      private const NEIGHBOR_PHOTO_Y_SPACING:Number = -15;
      
      private const NEIGHBOR_FRAME_X_SPACING:Number = -6;
      
      private var m_showingFriendSuggestRollout:Boolean = true;
      
      private var m_visitedUserName:String = "";
      
      public function NeighborVisitAvatar(neighborVisit:NeighborVisit, visitedUserName:String = "")
      {
         this.m_visitedUserName = visitedUserName;
         var neighborActionArray:Array = neighborVisit.neighborActions;
         for(var i:int = 0; i < neighborActionArray.length; i++)
         {
            if(getQualifiedClassName(neighborActionArray[i]).indexOf("TrickNeighborAction") != -1)
            {
               ++this.m_numTrickActions;
            }
         }
         super(neighborVisit.neighborId,neighborVisit.avatarData,neighborVisit.name,neighborVisit.isStranger);
         this.m_neighborVisit = neighborVisit;
         this.m_neighborActions = neighborVisit.neighborActions;
         this.m_workedObjects = neighborVisit.getWorkedObjects();
         this.m_arrow = new EmbeddedArt.harvestArrowNeighbor() as DisplayObject;
         this.m_neighborFrame = new EmbeddedArt.neighborFrame() as DisplayObject;
      }
      
      override public function showAvatar() : void
      {
         super.showAvatar();
      }
      
      override public function setHighlighted(highlighted:Boolean, color:uint = 16755200) : void
      {
         var action:BaseNeighborAction = null;
         var worldObject:WorldObject = null;
         if(highlighted && !this.m_enableAvatarMouseEvents)
         {
            return;
         }
         if(!Global.worldManager.isVisiting())
         {
            if(!this.m_hangOnToWorkedObjectsHighlight)
            {
               for each(action in this.m_neighborActions)
               {
                  worldObject = Global.world.getObjectById(action.objectId) as WorldObject;
                  if(Boolean(worldObject) && getQualifiedClassName(action).indexOf("TrickNeighborAction") != -1)
                  {
                     if(worldObject != null)
                     {
                        (worldObject as FarmGameObject).setHighlighted(highlighted,COLOR_HIGHLIGHT_ORANGE);
                     }
                  }
                  else if(worldObject != null)
                  {
                     (worldObject as FarmGameObject).setHighlighted(highlighted,Constants.COLOR_HIGHLIGHT_BLUE);
                  }
               }
               super.setHighlighted(highlighted,Constants.COLOR_HIGHLIGHT_BLUE);
            }
         }
         else
         {
            super.setHighlighted(true,NeighborVisitAvatar.COLOR_HIGHLIGHT_GREEN);
         }
      }
      
      public function executeActions() : void
      {
         var workedObject:FarmGameObject = null;
         this.m_neighborVisit.redeemActions(this);
         this.showPostMenuMode();
         for each(workedObject in this.m_workedObjects)
         {
            workedObject.onMouseOut();
         }
      }
      
      private function addRolloutWindow(picRolloutWindow:AbstractRolloutWindow, container:DisplayObjectContainer) : void
      {
         if(this.m_neighborFrame)
         {
            this.m_picRolloutWindow = picRolloutWindow;
            this.m_picRolloutWindow.y = this.m_neighborFrame.y;
            this.m_picRolloutWindow.x = this.m_neighborFrame.x + this.m_neighborFrame.width - 3;
            if(container)
            {
               container.addChildAt(this.m_picRolloutWindow,0);
            }
         }
      }
      
      private function showRolloutWindow() : void
      {
         if(this.m_picRolloutWindow)
         {
            if(Global.worldManager.isVisiting())
            {
               this.m_picRolloutWindow.addEventListener(FriendSuggestRollOutWindow.EVENT_BUTTON_CLICK,this.onRolloutButtonClick);
               this.m_showingFriendSuggestRollout = true;
            }
            else
            {
               this.setHighlighted(false);
               this.m_enableAvatarMouseEvents = false;
            }
            this.m_picRolloutWindow.tweenIn();
         }
      }
      
      private function hideRolloutWindow() : void
      {
         if(Global.worldManager.isVisiting())
         {
            this.m_picRolloutWindow.removeEventListener(FriendSuggestRollOutWindow.EVENT_BUTTON_CLICK,this.onRolloutButtonClick);
            this.m_showingFriendSuggestRollout = false;
            this.m_picRolloutWindow.tweenOut();
         }
      }
      
      public function onRolloutButtonClick(e:Event) : void
      {
         if(Global.worldManager.isVisiting())
         {
            Global.player.setSeenFlag("SEENFLAG_NeighborClickTest",true);
            this.hideRolloutWindow();
            this.detach();
         }
      }
      
      private function fadeOutWorkedObjectHighlights() : void
      {
         var workedObject:FarmGameObject = null;
         for each(workedObject in this.m_workedObjects)
         {
            workedObject.fadeHighlight(false,Constants.COLOR_HIGHLIGHT_BLUE,FADE_OUT_TIME_IN_SEC);
         }
      }
      
      private function onFadeOutComplete() : void
      {
         this.m_hangOnToWorkedObjectsHighlight = false;
         this.detach();
      }
      
      override public function onClick() : void
      {
         if(!this.m_enableAvatarMouseEvents)
         {
            return;
         }
         var menuItems:Array = [];
         var acceptLocalizeKey:String = "AcceptHelp";
         var dismissLocalizeKey:String = "Dismiss";
         var dismissAction:String = MENU_CANCEL;
         if(this.m_numTrickActions > 0)
         {
            menuItems.push({
               "label":ZLocUtils.t("FarmGame","TrickBack"),
               "action":TRICK_BACK
            });
            menuItems.push({
               "label":ZLocUtils.t("FarmGame","HideAltGraphic"),
               "action":HIDE_ALL_ALT_GRAPHIC
            });
            if(this.m_numTrickActions == this.m_neighborActions.length)
            {
               dismissLocalizeKey = "Okay";
               dismissAction = MENU_OKAY;
            }
         }
         if(this.m_numTrickActions < this.m_neighborActions.length)
         {
            menuItems.push({
               "label":ZLocUtils.t("FarmGame",acceptLocalizeKey),
               "action":MENU_ACCEPT
            });
         }
         menuItems.push({
            "label":ZLocUtils.t("FarmGame",dismissLocalizeKey),
            "action":dismissAction
         });
         UI.displayMenu(menuItems,this.onMenuClick);
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         UI.hideMenu();
         this.m_hangOnToWorkedObjectsHighlight = true;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case MENU_ACCEPT:
                  this.getStateMachine().addState(new AMNeighborWork(this),true);
                  FarmStatsManager.count(VisitorManager.NEIGHBOR_VISIT_COUNTER,VisitorManager.NEIGHBOR_VISIT_AVATAR_COUNTER,"avatar_neighbor_click","accept_actions");
                  StatsManager.social("accept",String(this.m_friendId),VisitorManager.NEIGHBOR_VISIT_COUNTER,"help");
                  break;
               case MENU_OKAY:
                  this.m_hangOnToWorkedObjectsHighlight = false;
                  FarmStatsManager.count(TrickOrTreatManager.instance.featureCreditName,"avatar","okay");
                  this.m_neighborVisit.clearActions();
                  this.fadeOutWorkedObjectHighlights();
                  this.removeVisitBack();
                  break;
               case MENU_CANCEL:
                  this.m_hangOnToWorkedObjectsHighlight = false;
                  FarmStatsManager.count(VisitorManager.NEIGHBOR_VISIT_COUNTER,VisitorManager.NEIGHBOR_VISIT_AVATAR_COUNTER,"avatar_neighbor_click","dismiss_actions");
                  StatsManager.social("reject",String(this.m_friendId),VisitorManager.NEIGHBOR_VISIT_COUNTER,"help");
                  this.m_neighborVisit.clearActions();
                  this.fadeOutWorkedObjectHighlights();
                  this.removeVisitBack();
                  break;
               case TRICK_BACK:
                  FarmStatsManager.count(TrickOrTreatManager.instance.featureCreditName,"avatars","trick_back");
                  Global.worldManager.visitNeighbor(String(this.m_friendId));
                  if(this.m_neighborActions.length - this.m_numTrickActions <= 0)
                  {
                     this.showPostMenuMode();
                  }
                  break;
               case HIDE_ALL_ALT_GRAPHIC:
                  FarmStatsManager.count(TrickOrTreatManager.instance.featureCreditName,"avatars","clean_up");
                  TrickOrTreatManager.instance.clearNeighborActionAltGraphics(this.m_neighborActions);
                  if(this.m_neighborActions.length - this.m_numTrickActions <= 0)
                  {
                     this.m_neighborVisit.clearActions();
                     this.showPostMenuMode();
                  }
            }
         }
      }
      
      override public function drawDisplayObject() : void
      {
         super.drawDisplayObject();
         var spr:Sprite = m_displayObject as Sprite;
         if(spr)
         {
            if(Global.worldManager.isVisiting())
            {
               this.setHighlighted(true,NeighborVisitAvatar.COLOR_HIGHLIGHT_GREEN);
            }
            if(this.m_neighborPic != null)
            {
               this.m_neighborPic.x = -m_character.width * 0.5 + this.NEIGHBOR_PHOTO_X_SPACING + this.NEIGHBOR_FRAME_X_SPACING;
               this.m_neighborPic.y = -m_character.height - this.m_neighborPic.height + this.NEIGHBOR_PHOTO_Y_SPACING;
               spr.addChild(this.m_neighborPic);
               this.m_neighborFrame.x = -m_character.width * 0.5 + this.NEIGHBOR_FRAME_X_SPACING;
               this.m_neighborFrame.y = -m_character.height - this.m_neighborFrame.height;
               spr.addChild(this.m_neighborFrame);
            }
            else if(this.m_arrow != null)
            {
               this.m_arrow.x = -m_character.width * 0.5 + this.m_arrow.width * 0.5;
               this.m_arrow.y = -m_character.height - this.m_arrow.height;
               spr.addChild(this.m_arrow);
            }
            if(this.m_neighborFrame)
            {
               if(Global.worldManager.isVisiting())
               {
                  if(this.m_showingFriendSuggestRollout)
                  {
                     if(!this.m_picRolloutWindow)
                     {
                        this.addRolloutWindow(new FriendSuggestRollOutWindow(this.m_visitedUserName,this.m_neighborVisit),spr);
                     }
                     else
                     {
                        this.addRolloutWindow(this.m_picRolloutWindow,spr);
                     }
                  }
               }
               else if(!this.m_picRolloutWindow)
               {
                  this.addRolloutWindow(new VisitBackRollOutWindow(m_friendId,m_friendName),spr);
               }
               else
               {
                  this.addRolloutWindow(this.m_picRolloutWindow,spr);
               }
            }
         }
      }
      
      override public function createDisplayObject() : DisplayObject
      {
         var displayObject:DisplayObject = super.createDisplayObject();
         m_character.addEventListener(Event.COMPLETE,this.onCharacterLoaded);
         if(this.m_numTrickActions)
         {
            m_character.alpha = 0.6;
            conditionallyRedraw(true);
         }
         return displayObject;
      }
      
      override protected function getLayerName() : String
      {
         return NEIGHBOR_AVATAR_LAYER;
      }
      
      private function onCharacterLoaded(event:Event) : void
      {
         m_character.removeEventListener(Event.COMPLETE,this.onCharacterLoaded);
         this.drawDisplayObject();
         var friend:Friend = Global.friendManager.getFriendData(this.m_neighborVisit.neighborId);
         if(!friend)
         {
            friend = Global.friendManager.getAppFriendData(this.m_neighborVisit.neighborId);
         }
         if(Global.worldManager.isVisiting())
         {
            if(this.m_neighborVisit.neighborPic != null)
            {
               this.m_neighborPicLoader = LoadingManager.load(this.m_neighborVisit.neighborPic,this.neighborPicLoaded);
            }
            else
            {
               this.m_neighborPicLoader = LoadingManager.load(Global.getAssetURL(Player.NO_PROFILE_PIC_URL),this.neighborPicLoaded);
            }
         }
         else if(friend != null)
         {
            if(friend.picture != null)
            {
               this.m_neighborPicLoader = LoadingManager.load(friend.picture,this.neighborPicLoaded);
            }
            else
            {
               this.m_neighborPicLoader = LoadingManager.load(Global.getAssetURL(Player.NO_PROFILE_PIC_URL),this.neighborPicLoaded);
            }
         }
      }
      
      private function showPostMenuMode() : void
      {
         this.fadeOutWorkedObjectHighlights();
         if(this.m_picRolloutWindow)
         {
            this.showRolloutWindow();
            this.m_picRolloutWindow.addEventListener(Event.CLOSE,this.onVisitBackRolloutClosed);
         }
         else
         {
            TweenLite.to(this.m_displayObject,FADE_OUT_TIME_IN_SEC,{
               "alpha":0,
               "onComplete":this.onFadeOutComplete
            });
         }
         Global.disableToolTips = false;
      }
      
      private function removeVisitBack() : void
      {
         if(this.m_picRolloutWindow)
         {
            this.m_picRolloutWindow.removeEventListener(Event.CLOSE,this.onVisitBackRolloutClosed);
            this.m_picRolloutWindow = null;
         }
         TweenLite.to(this.m_displayObject,FADE_OUT_TIME_IN_SEC,{
            "alpha":0,
            "onComplete":this.onFadeOutComplete
         });
         Global.disableToolTips = false;
      }
      
      private function onVisitBackRolloutClosed(event:Event) : void
      {
         this.removeVisitBack();
      }
      
      private function neighborPicLoaded(event:Event) : void
      {
         this.m_neighborPic = this.m_neighborPicLoader.content as Bitmap;
         if(this.m_neighborPic != null)
         {
            this.drawDisplayObject();
         }
      }
      
      override public function onMouseOver(event:MouseEvent) : void
      {
         if(Global.worldManager.isVisiting())
         {
            if(this.m_picRolloutWindow)
            {
               this.showRolloutWindow();
            }
         }
         else
         {
            Global.disableToolTips = this.m_neighborActions.length > Global.farmGameSettingsManager.getInt("neighborActionLimitFarm",5);
         }
         super.onMouseOver(event);
      }
      
      override public function onMouseOut() : void
      {
         var workedObject:FarmGameObject = null;
         if(Global.worldManager.isVisiting() && this.m_neighborVisit.isStranger)
         {
            FarmStatsManager.count("mutual_neighbor_click_exp","avatar_action","mouseover");
            if(this.m_picRolloutWindow)
            {
               this.hideRolloutWindow();
            }
         }
         else if(!this.m_enableAvatarMouseEvents)
         {
            return;
         }
         Global.disableToolTips = false;
         super.onMouseOut();
         for each(workedObject in this.m_workedObjects)
         {
            workedObject.onMouseOut();
         }
      }
   }
}

