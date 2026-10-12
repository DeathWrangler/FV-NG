package Classes
{
   import Display.ContextMenuItem;
   import Engine.Managers.SoundManager;
   import GameMode.GMHarvester;
   import GameMode.GMHarvesterAll;
   import Managers.TurboPPHManager;
   import flash.events.MouseEvent;
   
   public class Harvester extends Equipment
   {
      
      public static const HARVEST:String = "harvest";
      
      public function Harvester(itemName:String = null, active:Boolean = false, upgradeParts:Number = 0)
      {
         super(itemName,active,upgradeParts);
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case MOVE_OBJECT:
                  this.move();
                  break;
               case SELL_OBJECT:
                  this.sell();
                  break;
               case VEHICLE_ACTION:
                  if(TurboPPHManager.getInstance().turboSelected)
                  {
                     Global.world.addGameMode(new GMHarvesterAll(this));
                  }
                  else
                  {
                     Global.world.addGameMode(new GMHarvester(this));
                  }
                  break;
               case HORN:
                  SoundManager.addSound("harvesterHorn",Global.getAssetURL("assets/sounds/harvester_horn.mp3"));
                  SoundManager.playSound("harvesterHorn");
                  break;
               default:
                  super.onMenuClick(event);
            }
         }
      }
   }
}

