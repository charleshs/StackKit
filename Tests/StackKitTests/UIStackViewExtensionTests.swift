import XCTest
@testable import StackKit

final class UIStackViewExtensionTests: XCTestCase {
    private var aView: UIView!
    private var bView: UIView!
    private var cView: UIView!
    private var dView: UIView!
    private var newView: UIView!

    override func setUpWithError() throws {
        aView = UIView()
        bView = UIView()
        cView = UIView()
        dView = UIView()
        newView = UIView()
    }

    override func tearDownWithError() throws {
        aView = nil
        bView = nil
        cView = nil
        dView = nil
        newView = nil
    }

    func testConvenienceInit() {
        let stackView = UIStackView(axis: .vertical, alignment: .firstBaseline, distribution: .equalCentering, spacing: 87)

        XCTAssertEqual(stackView.axis, .vertical)
        XCTAssertEqual(stackView.alignment, .firstBaseline)
        XCTAssertEqual(stackView.distribution, .equalCentering)
        XCTAssertEqual(stackView.spacing, 87)
    }

    func testAddArrangedSubviews() {
        let stackView = UIStackView()
        let subviews: [UIView] = (0 ..< 5).map { _ in .init() }

        stackView.addArrangedSubviews(subviews)

        XCTAssertEqual(stackView.arrangedSubviews, subviews)
    }

    func testRemoveAllArrangedSubviews() {
        let stackView = UIStackView()
        let subviews: [UIView] = (0 ..< 5).map { _ in .init() }
        stackView.addArrangedSubviews(subviews)
        XCTAssertFalse(stackView.arrangedSubviews.isEmpty)

        stackView.removeAllArrangedSubviews()

        XCTAssertTrue(stackView.arrangedSubviews.isEmpty)
    }

    func testAddArrangedSubviewCustomSpacing() {
        let stackView = UIStackView(arrangedSubviews: [aView, bView, cView])
        let newView = UIView()

        stackView.addArrangedSubview(newView, spacingPrev: 77, spacingNext: 88)

        XCTAssertEqual(stackView.customSpacing(after: cView), 77)
        XCTAssertEqual(stackView.customSpacing(after: newView), 88)
    }

    func testInsertArrangedSubviewAtIndexCustomSpacing() {
        let stackView = UIStackView(arrangedSubviews: [aView, bView, cView])
        let newView = UIView()

        stackView.insertArrangedSubview(newView, at: 1, spacingPrev: 77, spacingNext: 88)

        XCTAssertEqual(stackView.customSpacing(after: aView), 77)
        XCTAssertEqual(stackView.customSpacing(after: newView), 88)
        XCTAssertEqual(stackView.arrangedSubviews, [aView, newView, bView, cView])
    }

    func testInsertArrangedSubviewBeforeExistingViewCustomSpacing() {
        let stackView = UIStackView(arrangedSubviews: [aView, bView, cView])
        let newView = UIView()

        stackView.insertArrangedSubview(newView, before: cView, spacingPrev: 77, spacingNext: 88)

        XCTAssertEqual(stackView.customSpacing(after: bView), 77)
        XCTAssertEqual(stackView.customSpacing(after: newView), 88)
        XCTAssertEqual(stackView.arrangedSubviews, [aView, bView, newView, cView])
    }

    func testInsertArrangedSubviewAfterExistingViewCustomSpacing() {
        let stackView = UIStackView(arrangedSubviews: [aView, bView, cView])
        let newView = UIView()

        stackView.insertArrangedSubview(newView, after: cView, spacingPrev: 77, spacingNext: 88)

        XCTAssertEqual(stackView.customSpacing(after: cView), 77)
        XCTAssertEqual(stackView.customSpacing(after: newView), 88)
        XCTAssertEqual(stackView.arrangedSubviews, [aView, bView, cView, newView])
    }

    func testInsertArrangedSubview_insertingViewExisting_shouldMoveTheExistingViewToNewPosition() {
        let stackView = UIStackView(arrangedSubviews: [aView, bView, cView, dView])

        stackView.insertArrangedSubview(dView, before: aView, spacingPrev: nil, spacingNext: nil)

        XCTAssertEqual(stackView.arrangedSubviews, [dView, aView, bView, cView])
    }

    func testInsertArrangedSubview_referenceViewNotExisting_shouldRemainUnchanged() {
        let stackView = UIStackView(arrangedSubviews: [aView, bView, cView])

        stackView.insertArrangedSubview(newView, after: dView, spacingPrev: nil, spacingNext: nil)

        XCTAssertEqual(stackView.arrangedSubviews, [aView, bView, cView])
    }

    func testInsertArrangedSubview_insertingAndReferenceViewAreIdentical_shouldRemainUnchanged() {
        let stackView = UIStackView(arrangedSubviews: [aView, bView, cView, dView])

        stackView.insertArrangedSubview(bView, before: bView, spacingPrev: nil, spacingNext: nil)

        XCTAssertEqual(stackView.arrangedSubviews, [aView, bView, cView, dView])
    }

    func testReplaceArrangedSubview() {
        let stackView = UIStackView(arrangedSubviews: [aView, bView, cView, dView])

        stackView.replaceArrangedSubview(bView, with: newView)

        XCTAssertEqual(stackView.arrangedSubviews, [aView, newView, cView, dView])
    }
}
