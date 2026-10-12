package Transactions
{
   public class TSetTerrainMapping extends TFarmTransaction
   {
      
      private var m_terrainPoints:Array = null;
      
      public function TSetTerrainMapping(terrainPoints:Array)
      {
         this.m_terrainPoints = terrainPoints;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("TerrainService.setTerrainMapping",this.m_terrainPoints);
      }
   }
}

