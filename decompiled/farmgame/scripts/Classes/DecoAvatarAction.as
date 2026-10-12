package Classes
{
   import AvatarMode.AMDeco;
   import AvatarMode.AMPath;
   import Classes.Constants.Experiments;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Engine.Classes.State;
   import Engine.Helpers.Vector3;
   import Engine.Managers.ErrorManager;
   import Managers.FarmStatsManager;
   import MyLife.Assets.Avatar.AvatarActions.ActionLibrary;
   import MyLife.Assets.Avatar.AvatarActions.AnimationAction;
   import MyLife.Events.AvatarActionEvent;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.getQualifiedClassName;
   
   public class DecoAvatarAction extends Decoration
   {
      
      protected static const INTERACT_OBJECT:String = "interactObject";
      
      private var m_class:Class;
      
      private var m_classString:String;
      
      private var m_isActive:Boolean;
      
      private const EXTRA_MC:String = "extra_anim";
      
      private var m_avatarLastScaleX:Number = 0.5;
      
      private var m_avatarLastScaleY:Number = 0.5;
      
      public function DecoAvatarAction(itemName:String = null)
      {
         super(itemName);
      }
      
      override protected function onItemImageLoaded(event:Event) : void
      {
         super.onImageLoaded(event);
         if(Global.selectedAvatar)
         {
            Global.selectedAvatar.getStateMachine().addEventListener(Event.CHANGE,this.onAvatarActionChanged);
         }
      }
      
      override public function showMenu() : void
      {
         m_menuItems = this.getMenuItems();
         super.showMenu();
         this.canShowSellMenuItem();
      }
      
      override protected function getMenuItems() : Array
      {
         var item:FarmItem = this.getItem();
         var menuItems:Array = new Array();
         if(item)
         {
            menuItems.push({
               "label":"Interact",
               "action":INTERACT_OBJECT
            });
         }
         if(item.allowMove)
         {
            menuItems.push({
               "label":ZLocUtils.t("FarmGame","Move"),
               "action":MOVE_OBJECT
            });
         }
         if(item.allowDelete && canShowSellMenuItem())
         {
            menuItems.push({
               "label":ZLocUtils.t("FarmGame","Sell"),
               "action":SELL_OBJECT
            });
         }
         return menuItems;
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case INTERACT_OBJECT:
                  if(!this.isAvatarPlaying())
                  {
                     this.activate();
                     FarmStatsManager.count("Interactive_Deco",m_originalItemName,"Interact");
                  }
                  break;
               default:
                  super.onMenuClick(event);
            }
         }
      }
      
      public function activate() : void
      {
         var anim:DisplayObject = null;
         if(m_content is MovieClip && m_content.hasOwnProperty("anim"))
         {
            this.m_classString = getQualifiedClassName(m_content["anim"]);
            if(this.m_classString != null)
            {
               this.m_class = m_content.loaderInfo.applicationDomain.getDefinition(this.m_classString) as Class;
               if(this.m_class)
               {
                  ActionLibrary.registerAnimationClipClass(this.m_class,this.m_classString);
                  Global.selectedAvatar.getStateMachine().addState(new AMDeco(Global.selectedAvatar,this),true);
               }
               else if(Config.DEBUG_MODE)
               {
                  ErrorManager.addError("Class path " + this.m_classString + " not found for interactive deco : " + m_itemName);
               }
            }
            else if(Config.DEBUG_MODE)
            {
               ErrorManager.addError("Class name not found for interactive deco : " + this.m_itemName);
            }
         }
      }
      
      public function onPathingCompleted() : void
      {
         if(m_content.hasOwnProperty(this.EXTRA_MC))
         {
            (m_content[this.EXTRA_MC] as MovieClip).visible = false;
         }
         if(Boolean(this.m_class) && this.m_classString.length > 0)
         {
            Global.selectedAvatar.getStateMachine().removeState(AMPath as State);
            this.setAvatarPosition();
            this.setAvatarSize();
            Global.selectedAvatar.getCharacter().doAvatarAction(this.m_classString,false,{"l":1});
            Global.selectedAvatar.getAvatarClip().getAvatarAction().addEventListener(AvatarActionEvent.ACTION_COMPLETE,this.onDecoAvatarActionDone);
            this.m_isActive = true;
            Global.selectedAvatar.isInteractingWithDecoItem = true;
            Global.selectedAvatar.showHideShadow(false);
         }
      }
      
      override protected function replaceContent(newContent:DisplayObject, shouldRedrawMask:Boolean = false) : void
      {
         if(!(m_content is MovieClip) || !(newContent is Bitmap))
         {
            super.replaceContent(newContent,shouldRedrawMask);
         }
      }
      
      private function setAvatarPosition() : void
      {
         Global.selectedAvatar.setAvatarDecoPosition(this.getPosition().x,this.getPosition().y);
         Global.selectedAvatar.conditionallyReattach(true);
      }
      
      private function setAvatarSize() : void
      {
         var size:Number = NaN;
         if(Global.selectedAvatar.lastScaleX >= 1 && Global.selectedAvatar.lastScaleY >= 1)
         {
            this.m_avatarLastScaleX = Global.selectedAvatar.lastScaleX;
            this.m_avatarLastScaleY = Global.selectedAvatar.lastScaleY;
            size = Global.farmGameSettingsManager.getNumber("avatarScale");
            Global.selectedAvatar.setScale(size);
         }
      }
      
      private function resetAvatarSize() : void
      {
         var size:Number = Global.farmGameSettingsManager.getNumber("avatarScale");
         if(this.m_avatarLastScaleX != size && this.m_avatarLastScaleY != size)
         {
            Global.selectedAvatar.setScale(this.m_avatarLastScaleX);
         }
      }
      
      private function onDecoAvatarActionDone(e:AvatarActionEvent) : void
      {
         Global.selectedAvatar.getAvatarClip().getAvatarAction().removeEventListener(AvatarActionEvent.ACTION_COMPLETE,this.onDecoAvatarActionDone);
         if(m_content.hasOwnProperty(this.EXTRA_MC))
         {
            (m_content[this.EXTRA_MC] as MovieClip).visible = true;
         }
         this.m_isActive = false;
         this.resetAvatar();
         FarmStatsManager.count("Interactive_Deco",m_originalItemName,"Interact_stop");
      }
      
      protected function resetAvatar() : void
      {
         Global.selectedAvatar.resetAvatarFrontClip();
         Global.selectedAvatar.getCharacter().doAvatarAction("standFront");
         this.resetAvatarSize();
         Global.selectedAvatar.isInteractingWithDecoItem = false;
         Global.selectedAvatar.showHideShadow(true);
      }
      
      private function onAvatarActionChanged(e:Event) : void
      {
         var states:Array = null;
         if(this.m_isActive)
         {
            states = Global.selectedAvatar.getStateMachine().getStates();
            if(states.length == 1 && states[0] is AMPath)
            {
               if(m_content.hasOwnProperty(this.EXTRA_MC))
               {
                  (m_content[this.EXTRA_MC] as MovieClip).visible = true;
               }
               this.m_isActive = false;
               Global.selectedAvatar.isInteractingWithDecoItem = false;
               Global.selectedAvatar.showHideShadow(true);
               this.resetAvatarSize();
               FarmStatsManager.count("Interactive_Deco",m_originalItemName,"Interact_stop");
            }
         }
      }
      
      public function getAvatarPosition() : Vector3
      {
         return Global.selectedAvatar.getPosition();
      }
      
      protected function isAvatarPlaying() : Boolean
      {
         var result:Boolean = false;
         var avatarAction:AnimationAction = Global.selectedAvatar.getAvatarClip().getAvatarAction();
         if(Boolean(avatarAction) && avatarAction.isPlaying())
         {
            result = true;
         }
         return result;
      }
      
      override public function stop() : void
      {
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_TOGGLE_INTERACTIVE_DECO) == Experiments.VARIANT_TOGGLE_ANIMATION)
         {
            super.pause();
         }
         else
         {
            super.stop();
         }
      }
   }
}

