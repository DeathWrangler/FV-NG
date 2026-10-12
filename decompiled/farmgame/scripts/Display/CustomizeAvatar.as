package Display
{
   import Classes.Avatar.FarmAvatar;
   import Engine.Managers.InputManager;
   import Engine.Managers.StatsManager;
   import MyLife.Events.GlobalEventManager;
   import MyLife.Events.SaveAvatarEvent;
   import MyLife.Interfaces.CreateNewPlayerStep0;
   import MyLife.NPC.SimpleNPC;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   
   public class CustomizeAvatar extends Sprite
   {
      
      public static const CLICK_BLOCKER_COLOR:Number = 0;
      
      public static const CLICK_BLOCKER_ALPHA:Number = 0.2;
      
      protected var m_avatar:FarmAvatar = null;
      
      protected var m_mcClickBlocker:MovieClip = new MovieClip();
      
      public var m_interfaceCreatePlayer:CreateNewPlayerStep0 = null;
      
      public var m_showCancel:Boolean;
      
      private var m_newAvatar:Boolean = false;
      
      private var m_showDialog:Boolean = true;
      
      public function CustomizeAvatar(showCancel:Boolean = false)
      {
         super();
         this.m_showCancel = showCancel;
      }
      
      public function show() : void
      {
         this.m_mcClickBlocker.graphics.clear();
         this.m_mcClickBlocker.graphics.beginFill(CLICK_BLOCKER_COLOR,CLICK_BLOCKER_ALPHA);
         this.m_mcClickBlocker.graphics.drawRect(0,0,Global.stage.stageWidth,Global.stage.stageHeight);
         this.m_mcClickBlocker.graphics.endFill();
         this.initialize();
      }
      
      public function set newAvatar(newAvatar:Boolean) : void
      {
         this.m_newAvatar = newAvatar;
      }
      
      public function get newAvatar() : Boolean
      {
         return this.m_newAvatar;
      }
      
      public function remove() : void
      {
         Global.stage.removeChild(this);
         Global.stage.removeChild(this.m_mcClickBlocker);
         this.m_mcClickBlocker = null;
         this.m_interfaceCreatePlayer = null;
      }
      
      protected function initialize() : void
      {
         var interfaceParams:Object = {
            "showCancel":this.m_showCancel,
            "playerId":0
         };
         interfaceParams.nameSelected = "My Farmer";
         interfaceParams.selectedGender = SimpleNPC.GENDER_FEMALE;
         if(Global.player.snUser.gender)
         {
            if("male" == Global.player.snUser.gender)
            {
               interfaceParams.selectedGender = SimpleNPC.GENDER_MALE;
            }
            this.m_showDialog = false;
         }
         this.m_interfaceCreatePlayer = new CreateNewPlayerStep0(Global.avatarConfigSettings.getLoader());
         this.m_interfaceCreatePlayer.initialize(interfaceParams);
         StatsManager.milestone("gender_md");
         GlobalEventManager.getInstance().addEventListener(SaveAvatarEvent.SAVE,this.onAvatarSave);
         if(this.m_showDialog)
         {
            InputManager.disableInput();
            Global.stage.addChild(this.m_mcClickBlocker);
            Global.stage.addChild(this.m_interfaceCreatePlayer);
            CreateNewPlayerStep0.showDialog(this.m_interfaceCreatePlayer,this.m_interfaceCreatePlayer.width,this.m_interfaceCreatePlayer.height);
         }
         else
         {
            this.m_interfaceCreatePlayer.skipDialog();
         }
      }
      
      protected function onAvatarSave(ev:Object) : void
      {
         if(this.m_showDialog)
         {
            InputManager.enableInput();
         }
         this.m_mcClickBlocker.graphics.clear();
         GlobalEventManager.getInstance().removeEventListener(SaveAvatarEvent.SAVE,this.onAvatarSave);
         dispatchEvent(new SaveAvatarEvent(SaveAvatarEvent.SAVE,ev.customizationData,ev.gender,ev.avatarName));
         if(this.m_showDialog)
         {
            dispatchEvent(new Event(Event.CLOSE));
         }
      }
   }
}

