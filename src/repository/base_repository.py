class BaseRepository:
    """데이터베이스 접근 기초 클래스"""
    def __init__(self, db_url: str):
        self.db_url = db_url

    def save(self, entity):
        """엔티티 저장 (Mock)"""
        print(f"Entity saved to {self.db_url}: {entity}")
        return True

    def find_by_id(self, entity_id: int):
        """ID로 조회 (Mock)"""
        return None
