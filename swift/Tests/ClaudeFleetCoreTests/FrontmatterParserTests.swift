import XCTest
@testable import ClaudeFleetCore

final class FrontmatterParserTests: XCTestCase {
    func testSplitWithFrontmatter() {
        let content = """
        ---
        name: foo
        description: bar
        ---
        body line 1
        body line 2
        """
        let result = FrontmatterParser.split(content)
        XCTAssertEqual(result.yamlString, "name: foo\ndescription: bar")
        XCTAssertEqual(result.body, "body line 1\nbody line 2")
    }

    func testSplitNoFrontmatter() {
        let content = "no frontmatter here\njust body"
        let result = FrontmatterParser.split(content)
        XCTAssertEqual(result.yamlString, "")
        XCTAssertEqual(result.body, content)
    }

    func testSplitToleratesCRLF() {
        let content = "---\r\nname: foo\r\n---\r\nbody"
        let result = FrontmatterParser.split(content)
        XCTAssertEqual(result.yamlString, "name: foo")
        XCTAssertEqual(result.body, "body")
    }

    func testSplitToleratesBOM() {
        let content = "\u{FEFF}---\nname: foo\n---\nbody"
        let result = FrontmatterParser.split(content)
        XCTAssertEqual(result.yamlString, "name: foo")
    }

    func testSplitMissingClosingFenceFallsBackToBody() {
        let content = "---\nname: foo\nbody without closing fence"
        let result = FrontmatterParser.split(content)
        XCTAssertEqual(result.yamlString, "")
        XCTAssertEqual(result.body, content)
    }

    func testParseDictEmpty() throws {
        XCTAssertEqual(try FrontmatterParser.parseDict("").count, 0)
        XCTAssertEqual(try FrontmatterParser.parseDict("   \n   ").count, 0)
    }

    func testParseDictBasic() throws {
        let dict = try FrontmatterParser.parseDict("name: foo\ndescription: bar\ncount: 3")
        XCTAssertEqual(dict["name"] as? String, "foo")
        XCTAssertEqual(dict["description"] as? String, "bar")
        XCTAssertEqual(dict["count"] as? Int, 3)
    }

    func testParseDictListAndNested() throws {
        let yaml = """
        skills:
          - one
          - two
        hooks:
          - event: Stop
            command: ./x.sh
        """
        let dict = try FrontmatterParser.parseDict(yaml)
        XCTAssertEqual(dict["skills"] as? [String], ["one", "two"])
        let hooks = dict["hooks"] as? [Any]
        XCTAssertEqual(hooks?.count, 1)
    }

    func testParseDictFailsOnNonMapping() {
        XCTAssertThrowsError(try FrontmatterParser.parseDict("- just\n- a\n- list"))
    }

    func testParseDictFailsOnGarbage() {
        XCTAssertThrowsError(try FrontmatterParser.parseDict("name: [unclosed"))
    }
}
