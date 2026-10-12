package Classes.PphToDo
{
   import Classes.ImageLoader;
   import Classes.Seeder;
   import Classes.ZItem.FarmItem;
   import Display.QueuedIcon;
   import Engine.Managers.TransactionManager;
   import GameMode.GMMarketPlant;
   import GameMode.GMSeeder;
   import Managers.FarmStatsManager;
   import Transactions.TPphToDoTakeAction;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class PphAction
   {
      
      protected var m_crop:FarmItem = null;
      
      protected var m_hudIcon:QueuedIcon = null;
      
      protected var m_hudIconName:String = "PPHToDoList";
      
      public function PphAction()
      {
         super();
      }
      
      public function createData() : Boolean
      {
         return false;
      }
      
      public function getHudIcon() : QueuedIcon
      {
         this.m_hudIcon = Global.hud.iconQueue.addIconToTop(this.m_hudIconName);
         this.m_hudIcon.contentManip = this.onIconLoaded;
         this.attachHudIconToolTip();
         FarmStatsManager.count("game_to_do_list",this.getStatKingdom(),"icon_impressions",this.m_crop.name);
         return this.m_hudIcon;
      }
      
      public function takeAction() : void
      {
         var seeder:Seeder = null;
         var hasFuel:Boolean = false;
         if(this.m_crop != null)
         {
            seeder = Global.world.getEquipment(Seeder) as Seeder;
            hasFuel = Global.player.hasEnergy(0,false);
            if(seeder != null && hasFuel)
            {
               Global.world.addGameMode(new GMSeeder(this.m_crop,seeder));
            }
            else
            {
               Global.world.addGameMode(new GMMarketPlant(this.m_crop.name));
            }
            TransactionManager.addTransaction(new TPphToDoTakeAction());
            FarmStatsManager.count("game_to_do_list",this.getStatKingdom(),"icon_clicks",this.m_crop.name);
         }
      }
      
      protected function getStatKingdom() : String
      {
         return "PPH_action_event";
      }
      
      protected function attachHudIconToolTip() : void
      {
      }
      
      protected function onIconLoaded(content:DisplayObject) : void
      {
         var imageLoader:ImageLoader = ImageLoader.getInstance(this.m_crop.icon);
         imageLoader.getContent(this.addCropIconToHudIcon);
      }
      
      protected function addCropIconToHudIcon(content:DisplayObject) : void
      {
         var iconContent:MovieClip = this.m_hudIcon.getContent() as MovieClip;
         if(iconContent)
         {
            if(iconContent.icon_mc != null)
            {
               content.scaleX = content.scaleY = 0.5;
               iconContent.icon_mc.addChild(content);
            }
         }
      }
   }
}

